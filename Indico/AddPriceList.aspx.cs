using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic;
using System.Transactions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;

using Indico.BusinessObjects;
using Indico.Common;
using Excel = Microsoft.Office.Interop.Excel;
using System.IO;
using System.Text;
using System.Threading;
using System.Web.Services;

using ClosedXML.Excel;

namespace Indico
{
    public partial class AddPriceList : IndicoPage
    {
        #region Fields

        //private int onProgressCount = 0;
        // private string textFilePath = IndicoConfiguration.AppConfiguration.PathToDataFolder + @"\Temp\progress.txt";
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

        protected void btnDownloadExcel_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                if (Page.IsValid)
                {
                    #region PriceTerm

                    int priceTerm = 0;
                    string priceTermName = string.Empty;
                    if (rbcifPrice.Checked == true)
                    {
                        priceTerm = 1;
                        priceTermName = "CIF Price";
                    }
                    else if (rbfobPrice.Checked == true)
                    {
                        priceTerm = 2;
                        priceTermName = "FOB Price";
                    }

                    #endregion

                    string fileName = this.ddlDistributorsExcel.SelectedItem.Text.Trim().ToUpper() + "_" + ((priceTerm == 1) ? "CIF" : "FOB") + "_" + DateTime.Now.ToString("ddMMyyyyhhmmss") + ".xlsx";
                    DefaultValuesPriceListBO objDefaultPriceList = new DefaultValuesPriceListBO().SearchObjects().SingleOrDefault();
                    try
                    {
                        using (TransactionScope ts = new TransactionScope())
                        {
                            PriceListDownloadsBO objDownload = new PriceListDownloadsBO(this.ObjContext);
                            objDownload.Creator = this.LoggedUser.ID;
                            objDownload.CreatedDate = Convert.ToDateTime(DateTime.Now.ToString("g"));

                            // Terms
                            int distributor = int.Parse(this.ddlDistributorsExcel.SelectedValue.Trim());
                            if (distributor > 0)
                            {
                                objDownload.Distributor = distributor;
                            }
                            objDownload.PriceTerm = ((this.rbcifPrice.Checked) ? 1 : 0);
                            objDownload.EditedPrice = (this.rbeditedPrice.Checked);

                            // Design
                            if (checkCreativeDesign.Checked)
                            {
                                if (!String.IsNullOrEmpty(this.txtCreativeDesign.Text) && this.txtCreativeDesign.Text != objDefaultPriceList.CreativeDesign.ToString())
                                {
                                    objDownload.CreativeDesign = decimal.Parse(this.txtCreativeDesign.Text);
                                }
                                else
                                {
                                    objDownload.CreativeDesign = decimal.Parse(objDefaultPriceList.CreativeDesign.ToString());
                                }
                            }
                            if (checkStudioDesign.Checked)
                            {
                                if (!String.IsNullOrEmpty(this.txtStudioDesign.Text) && this.txtStudioDesign.Text != objDefaultPriceList.StudioDesign.ToString())
                                {
                                    objDownload.StudioDesign = decimal.Parse(this.txtStudioDesign.Text);
                                }
                                else
                                {
                                    objDownload.StudioDesign = decimal.Parse(objDefaultPriceList.StudioDesign.ToString());
                                }
                            }
                            if (checkThirdPartyDesign.Checked)
                            {
                                if (!String.IsNullOrEmpty(this.txtThirdPartyDesign.Text) && this.txtThirdPartyDesign.Text != objDefaultPriceList.ThirdPartyDesign.ToString())
                                {
                                    objDownload.ThirdPartyDesign = decimal.Parse(this.txtThirdPartyDesign.Text);
                                }
                                else
                                {
                                    objDownload.ThirdPartyDesign = decimal.Parse(objDefaultPriceList.ThirdPartyDesign.ToString());
                                }
                            }

                            // Position
                            if (checkPositionOne.Checked)
                            {
                                if (!String.IsNullOrEmpty(this.txtPositionOne.Text) && this.txtPositionOne.Text != objDefaultPriceList.Position1.ToString())
                                {
                                    objDownload.Position1 = decimal.Parse(this.txtPositionOne.Text);
                                }
                                else
                                {
                                    objDownload.Position1 = decimal.Parse(objDefaultPriceList.Position1.ToString());
                                }
                            }
                            if (checkPositionTwo.Checked)
                            {
                                if (!String.IsNullOrEmpty(this.txtPositionTwo.Text) && this.txtPositionTwo.Text != objDefaultPriceList.Position2.ToString())
                                {
                                    objDownload.Position2 = decimal.Parse(this.txtPositionTwo.Text);
                                }
                                else
                                {
                                    objDownload.Position2 = decimal.Parse(objDefaultPriceList.Position2.ToString());
                                }
                            }
                            if (checkPositionThree.Checked)
                            {
                                if (!String.IsNullOrEmpty(this.txtPositionThree.Text) && this.txtPositionThree.Text != objDefaultPriceList.Position3.ToString())
                                {
                                    objDownload.Position3 = decimal.Parse(this.txtPositionThree.Text);
                                }
                                else
                                {
                                    objDownload.Position3 = decimal.Parse(objDefaultPriceList.Position3.ToString());
                                }
                            }
                            objDownload.PriceTerm = priceTerm;
                            objDownload.FileName = fileName;

                            this.ObjContext.SaveChanges();
                            ts.Complete();
                        }

                    }
                    catch (Exception ex)
                    {
                        // Log the error
                        IndicoLogging.log.Error("btnDownloadExcel_Click, PriceListDownloadsBO : Error occured while updating database.", ex);
                    }

                    string filePath = String.Format("{0}{1}", (IndicoConfiguration.AppConfiguration.PathToDataFolder + @"\PriceLists\"), fileName);

                    Session["ExcelDocumetPath_" + this.LoggedUser.ID.ToString()] = filePath;

                    Thread oThread = new Thread(new ThreadStart(() => GenerateExcel(filePath, priceTerm, priceTermName)));
                    oThread.IsBackground = true;
                    oThread.Start();

                }

                Response.Redirect("/ViewPriceLists.aspx");
            }
        }

        protected void btnSaveDefaultValue_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                if (Page.IsValid)
                {
                    int defaultID = 0;
                    try
                    {
                        DefaultValuesPriceListBO objDefaultPriceList = new DefaultValuesPriceListBO().SearchObjects().SingleOrDefault();
                        if (objDefaultPriceList != null)
                        {
                            defaultID = objDefaultPriceList.ID;
                        }
                        using (TransactionScope ts = new TransactionScope())
                        {
                            DefaultValuesPriceListBO objDefaultValuesPrice = new DefaultValuesPriceListBO(this.ObjContext);
                            if (defaultID > 0)
                            {
                                objDefaultValuesPrice.ID = defaultID;
                                objDefaultValuesPrice.GetObject();
                            }
                            else
                            {
                                objDefaultValuesPrice.Creator = LoggedUser.ID;
                                objDefaultValuesPrice.CreatedDate = DateTime.Now;
                            }

                            objDefaultValuesPrice.CreativeDesign = int.Parse(this.txtAddCreativeDesign.Text);
                            objDefaultValuesPrice.StudioDesign = int.Parse(this.txtAddStudioDesign.Text);
                            objDefaultValuesPrice.ThirdPartyDesign = int.Parse(this.txtAddThirdParydesign.Text);
                            objDefaultValuesPrice.Position1 = int.Parse(this.txtAddPosition1.Text);
                            objDefaultValuesPrice.Position2 = int.Parse(this.txtAddPosition2.Text);
                            objDefaultValuesPrice.Position3 = int.Parse(this.txtAddPosition3.Text);
                            objDefaultValuesPrice.Modifier = LoggedUser.ID;
                            objDefaultValuesPrice.ModifiedDate = DateTime.Now;

                            ObjContext.SaveChanges();
                            ts.Complete();
                        }
                    }
                    catch (Exception ex)
                    {

                        IndicoLogging.log.Error("Error occured while saving default price list values", ex);
                    }
                }
            }
            ViewState["populateDefaultValue"] = false;

        }

        protected void btnDefaultValue_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                DefaultValuesPriceListBO objDefaultPriceList = new DefaultValuesPriceListBO().SearchObjects().SingleOrDefault();
                try
                {
                    if (objDefaultPriceList != null)
                    {
                        this.txtAddCreativeDesign.Text = objDefaultPriceList.CreativeDesign.ToString();
                        this.txtAddStudioDesign.Text = objDefaultPriceList.StudioDesign.ToString();
                        this.txtAddThirdParydesign.Text = objDefaultPriceList.ThirdPartyDesign.ToString();
                        this.txtAddPosition1.Text = objDefaultPriceList.Position1.ToString();
                        this.txtAddPosition2.Text = objDefaultPriceList.Position2.ToString();
                        this.txtAddPosition3.Text = objDefaultPriceList.Position3.ToString();
                    }
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while populate Default Values", ex);
                }
                ViewState["populateDefaultValue"] = true;
            }
            else
            {
                ViewState["populateDefaultValue"] = false;
            }
        }

        protected void btnDownloadLabelExcel_Click(object sender, EventArgs e)
        {
            if (this.ddlLabelExcel.SelectedIndex != 0)
            {
                #region PriceTerm

                int priceTerm = 0;
                string priceTermName = string.Empty;
                if (rbcifPrice.Checked == true)
                {
                    priceTerm = 1;
                    priceTermName = "CIF Price";
                }
                else if (rbfobPrice.Checked == true)
                {
                    priceTerm = 2;
                    priceTermName = "FOB Price";
                }

                #endregion

                string fileName = this.ddlLabelExcel.SelectedItem.Text.Trim().ToUpper() + "_" + ((priceTerm == 1) ? "CIF" : "FOB") + "_" + DateTime.Now.ToString("ddMMyyyyhhmmss") + ".xlsx";
                DefaultValuesPriceListBO objDefaultPriceList = new DefaultValuesPriceListBO().SearchObjects().SingleOrDefault();
                try
                {
                    using (TransactionScope ts = new TransactionScope())
                    {
                        LabelPriceListDownloadsBO objLabelDownload = new LabelPriceListDownloadsBO(this.ObjContext);
                        objLabelDownload.Creator = this.LoggedUser.ID;
                        objLabelDownload.CreatedDate = Convert.ToDateTime(DateTime.Now.ToString("g"));

                        // Terms
                        int label = int.Parse(this.ddlLabelExcel.SelectedValue.Trim());
                        if (label > 0)
                        {
                            objLabelDownload.Label = label;
                        }
                        objLabelDownload.PriceTerm = ((this.rbcifPrice.Checked) ? 1 : 0);
                        objLabelDownload.EditedPrice = (this.rbeditedPrice.Checked);

                        // Design
                        if (checkCreativeDesign.Checked)
                        {
                            if (!String.IsNullOrEmpty(this.txtCreativeDesign.Text) && this.txtCreativeDesign.Text != objDefaultPriceList.CreativeDesign.ToString())
                            {
                                objLabelDownload.CreativeDesign = decimal.Parse(this.txtCreativeDesign.Text);
                            }
                            else
                            {
                                objLabelDownload.CreativeDesign = decimal.Parse(objDefaultPriceList.CreativeDesign.ToString());
                            }
                        }
                        if (checkStudioDesign.Checked)
                        {
                            if (!String.IsNullOrEmpty(this.txtStudioDesign.Text) && this.txtStudioDesign.Text != objDefaultPriceList.StudioDesign.ToString())
                            {
                                objLabelDownload.StudioDesign = decimal.Parse(this.txtStudioDesign.Text);
                            }
                            else
                            {
                                objLabelDownload.StudioDesign = decimal.Parse(objDefaultPriceList.StudioDesign.ToString());
                            }
                        }
                        if (checkThirdPartyDesign.Checked)
                        {
                            if (!String.IsNullOrEmpty(this.txtThirdPartyDesign.Text) && this.txtThirdPartyDesign.Text != objDefaultPriceList.ThirdPartyDesign.ToString())
                            {
                                objLabelDownload.ThirdPartyDesign = decimal.Parse(this.txtThirdPartyDesign.Text);
                            }
                            else
                            {
                                objLabelDownload.ThirdPartyDesign = decimal.Parse(objDefaultPriceList.ThirdPartyDesign.ToString());
                            }
                        }

                        // Position
                        if (checkPositionOne.Checked)
                        {
                            if (!String.IsNullOrEmpty(this.txtPositionOne.Text) && this.txtPositionOne.Text != objDefaultPriceList.Position1.ToString())
                            {
                                objLabelDownload.Position1 = decimal.Parse(this.txtPositionOne.Text);
                            }
                            else
                            {
                                objLabelDownload.Position1 = decimal.Parse(objDefaultPriceList.Position1.ToString());
                            }
                        }
                        if (checkPositionTwo.Checked)
                        {
                            if (!String.IsNullOrEmpty(this.txtPositionTwo.Text) && this.txtPositionTwo.Text != objDefaultPriceList.Position2.ToString())
                            {
                                objLabelDownload.Position2 = decimal.Parse(this.txtPositionTwo.Text);
                            }
                            else
                            {
                                objLabelDownload.Position2 = decimal.Parse(objDefaultPriceList.Position2.ToString());
                            }
                        }
                        if (checkPositionThree.Checked)
                        {
                            if (!String.IsNullOrEmpty(this.txtPositionThree.Text) && this.txtPositionThree.Text != objDefaultPriceList.Position3.ToString())
                            {
                                objLabelDownload.Position3 = decimal.Parse(this.txtPositionThree.Text);
                            }
                            else
                            {
                                objLabelDownload.Position3 = decimal.Parse(objDefaultPriceList.Position3.ToString());
                            }
                        }
                        objLabelDownload.PriceTerm = priceTerm;
                        objLabelDownload.FileName = fileName;

                        this.ObjContext.SaveChanges();
                        ts.Complete();
                    }

                }
                catch (Exception ex)
                {
                    // Log the error
                    IndicoLogging.log.Error("btnDownloadExcel_Click, PriceListDownloadsBO : Error occured while updating database.", ex);
                }

                string filePath = String.Format("{0}{1}", (IndicoConfiguration.AppConfiguration.PathToDataFolder + @"\PriceLists\"), fileName);

                Session["ExcelDocumetPath_" + this.LoggedUser.ID.ToString()] = filePath;


                Thread oThread = new Thread(new ThreadStart(() => GenerateLabelExcel(filePath, priceTerm, priceTermName)));
                oThread.IsBackground = true;
                oThread.Start();

                Response.Redirect("/ViewPriceLists.aspx");

            }
            else
            {
                CustomValidator customValidator = new CustomValidator();
                customValidator.ErrorMessage = "Please select label";
                customValidator.IsValid = false;
                customValidator.EnableClientScript = false;
                customValidator.ValidationGroup = "pricelistLabel";

                this.PriceListvalidationSummary.Controls.Add(customValidator);
                ViewState["ClonePriceMarkup"] = true;

                this.lilabel.Attributes.Add("style", "display:block");
                this.lidistributor.Attributes.Add("style", "display:none");
            }

        }
        #endregion

        #region Methods

        /// <summary>
        /// Populate the controls.
        /// </summary>
        private void PopulateControls()
        {
            ViewState["populateDefaultValue"] = false;

            // Header Text
            this.litHeaderText.Text = this.ActivePage.Heading;

            // Populate Distributors create dropdown download excel sheet                
            this.ddlDistributorsExcel.Items.Add(new ListItem("PLATINUM", "0"));
            List<int> lstDistributoridsExcel = (new DistributorPriceMarkupBO()).SearchObjects().Where(o => o.Distributor != 0 && o.objDistributor.IsActive == true && o.objDistributor.IsDelete == false).Select(m => (int)m.Distributor).Distinct().ToList();
            foreach (int id in lstDistributoridsExcel)
            {
                CompanyBO objCompany = new CompanyBO();
                objCompany.ID = id;
                objCompany.GetObject();
                this.ddlDistributorsExcel.Items.Add(new ListItem(objCompany.Name, objCompany.ID.ToString()));
            }

            // populate Labels create dropdown download excel sheet
            this.ddlLabelExcel.Items.Add(new ListItem("Select Your Label", "0"));
            List<int> lstLabels = (new LabelPriceMarkupBO()).SearchObjects().Select(o => (int)o.Label).Distinct().ToList();
            foreach (int label in lstLabels)
            {
                PriceMarkupLabelBO objPriceMarkupLabel = new PriceMarkupLabelBO();
                objPriceMarkupLabel.ID = label;
                objPriceMarkupLabel.GetObject();
                this.ddlLabelExcel.Items.Add(new ListItem(objPriceMarkupLabel.Name, objPriceMarkupLabel.ID.ToString()));
            }

            // hide the Edited Price and Calculated price
            this.dvHide.Visible = false;

            // To writer the progress text file.
            this.hdnUserID.Value = this.LoggedUser.ID.ToString();

            // Populate generating div
            ViewState["IsPageValied"] = false;
            ViewState["populateDefaultValue"] = false;

            // set default values to the btndefaultvaluesfees
            DefaultValuesPriceListBO objDefaultPriceList = new DefaultValuesPriceListBO().SearchObjects().SingleOrDefault();
            this.checkCreativeDesign.Attributes.Add("df", objDefaultPriceList.CreativeDesign.ToString());
            this.checkStudioDesign.Attributes.Add("df", objDefaultPriceList.StudioDesign.ToString());
            this.checkThirdPartyDesign.Attributes.Add("df", objDefaultPriceList.ThirdPartyDesign.ToString());
            this.checkPositionOne.Attributes.Add("df", objDefaultPriceList.Position1.ToString());
            this.checkPositionTwo.Attributes.Add("df", objDefaultPriceList.Position2.ToString());
            this.checkPositionThree.Attributes.Add("df", objDefaultPriceList.Position3.ToString());

        }

        /// <summary>
        /// Generate Excel Document
        /// </summary>
        /// <param name="filePath">Excel file path to save</param>
        /// <param name="priceTerm">Price terms</param>
        /// <param name="priceTermName">Price terms names</param>
        //private void GenerateExcel(string filePath, int priceTerm, string priceTermName)
        //{
        //    // get a write lock on scCacheKeys
        //    IndicoPage.RWLock.AcquireWriterLock(Timeout.Infinite);

        //    // Excel
        //    //double xlProgress = 0;
        //    int i = 0;
        //    string creativeDesign = string.Empty;
        //    string studioDesign = string.Empty;
        //    string thirdPartyDesign = string.Empty;
        //    string position1 = string.Empty;
        //    string position2 = string.Empty;
        //    string position3 = string.Empty;
        //    string priceValidDate = string.Empty;
        //    int row = 7;

        //    DefaultValuesPriceListBO objDefaultPriceList = new DefaultValuesPriceListBO().SearchObjects().SingleOrDefault();
        //    //string lines = xlProgress.ToString();           

        //    CreateExcelDocument excell_app = new CreateExcelDocument(true);

        //    #region checkDesign

        //    if (checkCreativeDesign.Checked)
        //    {
        //        if (!string.IsNullOrEmpty(txtCreativeDesign.Text) && this.txtCreativeDesign.Text != objDefaultPriceList.CreativeDesign.ToString())
        //        {
        //            creativeDesign = "Creative Design Set Up Fee: $" + txtCreativeDesign.Text + " + GST per Job";
        //        }
        //        else
        //        {
        //            creativeDesign = "Creative Design Set Up Fee: $" + objDefaultPriceList.CreativeDesign.ToString() + " + GST per Job";
        //        }
        //    }
        //    if (checkStudioDesign.Checked)
        //    {
        //        if (!string.IsNullOrEmpty(txtStudioDesign.Text) && this.txtStudioDesign.Text != objDefaultPriceList.StudioDesign.ToString())
        //        {
        //            studioDesign = "Studio Design Set Up Fee: $" + txtStudioDesign.Text + " + GST per Job";
        //        }
        //        else
        //        {
        //            studioDesign = "Studio Design Set Up Fee: $" + objDefaultPriceList.StudioDesign.ToString() + " + GST per Job";
        //        }
        //    }
        //    if (checkThirdPartyDesign.Checked)
        //    {
        //        if (!string.IsNullOrEmpty(txtThirdPartyDesign.Text) && this.txtThirdPartyDesign.Text != objDefaultPriceList.ThirdPartyDesign.ToString())
        //        {
        //            thirdPartyDesign = "Third Party Design Set Up Fee: $" + txtThirdPartyDesign.Text + " + GST per Job";
        //        }
        //        else
        //        {
        //            thirdPartyDesign = "Third Party Design Set Up Fee: $" + objDefaultPriceList.ThirdPartyDesign.ToString() + " + GST per Job";
        //        }
        //    }

        //    #endregion

        //    #region checkPsotion

        //    if (checkPositionOne.Checked)
        //    {
        //        if (!string.IsNullOrEmpty(txtPositionOne.Text) && this.txtPositionOne.Text != objDefaultPriceList.Position1.ToString())
        //        {
        //            position1 = "1 x Position @ $" + txtPositionOne.Text + " - eg name on left chest";
        //        }
        //        else
        //        {
        //            position1 = "1 x Position @ $" + objDefaultPriceList.Position1.ToString() + " - eg name on left chest";
        //        }
        //    }
        //    if (checkPositionTwo.Checked)
        //    {
        //        if (!string.IsNullOrEmpty(txtPositionTwo.Text) && this.txtPositionTwo.Text != objDefaultPriceList.Position2.ToString())
        //        {
        //            position2 = "2 x Positions @ $" + txtPositionTwo.Text + " - eg names on left chest and upper back";
        //        }
        //        else
        //        {
        //            position2 = "2 x Positions @ $" + objDefaultPriceList.Position2.ToString() + " - eg names on left chest and upper back";
        //        }
        //    }
        //    if (checkPositionThree.Checked)
        //    {
        //        if (!string.IsNullOrEmpty(txtPositionThree.Text) && this.txtPositionThree.Text != objDefaultPriceList.Position3.ToString())
        //        {
        //            position3 = "3 x Positions @ $" + txtPositionThree.Text + " - eg names on left chest, upper back and number on lower back";
        //        }
        //        else
        //        {
        //            position3 = "3 x Positions @ $" + objDefaultPriceList.Position3.ToString() + " - eg names on left chest, upper back and number on lower back";
        //        }
        //    }
        //    #endregion

        //    try
        //    {
        //        int distributor = int.Parse(this.ddlDistributorsExcel.SelectedValue);

        //        String excelType = string.Empty;
        //        PriceBO objPrice = new PriceBO();
        //        ExcelPriceLevelCostViewBO excel = new ExcelPriceLevelCostViewBO();
        //        List<ExcelPriceLevelCostViewBO> lstpr = (from o in excel.SearchObjects()
        //                                                 orderby o.SportsCategory
        //                                                 select o).ToList();

        //        // first row
        //        excell_app.AddHeaderData(1, 1, "" + this.ddlDistributorsExcel.SelectedItem.Text.ToUpper() + " - " + priceTermName + " PRICE LIST ALL PLUS GST PLUS LOCAL FREIGHT EX-ADELAIDE", "A1", "D1", true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignLeft, "General");
        //        // Second row
        //        excell_app.AddHeaderData(2, 1, "INDICO PTY LTD", "A2", "B2", true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignLeft, "General");
        //        excell_app.AddHeaderData(2, 3, "Published Date: " + DateTime.Now.ToString("dd MMMM yyyy") + "", "C2", "D2", true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignLeft, "General");
        //        excell_app.AddHeaderData(2, 5, "" + creativeDesign + "     " + studioDesign + "     " + thirdPartyDesign + "", "E2", "F2", true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignLeft, "General");
        //        excell_app.AddHeaderData(2, 9, "QUANTITY", "G2", "N2", true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        // Third row
        //        // excell_app.AddHeaderData(3, 3, priceValidDate, "C5", "D5", true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignLeft, "dd MMMM yyyy");
        //        // Fourth row
        //        excell_app.AddHeaderData(4, 1, "Individual Names & Numbers are charged as follows:     " + position1 + "     " + position2 + "    " + position3 + " ", "A4", "F4", true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignLeft, "General");
        //        excell_app.AddHeaderData(4, 9, "All re-orders under 20 units wll have the benefit of receiving the 20 unit price", "G4", "N4", true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        // Column headers
        //        excell_app.AddHeaderData(6, 1, "SPORTS CATEGORY", "A6", "A6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(6, 2, "OTHER CATEGORIES", "B6", "B6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(6, 3, "PATTERN", "C6", "C6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(6, 4, "ITEM SUB CATEGORY", "D6", "D6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(6, 5, "DESCRIPTION", "E6", "E6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(6, 6, "FABRIC", "F6", "F6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderDataWithBackgroundColor(6, 7, "'1-5", "G6", "G6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter);
        //        excell_app.AddHeaderDataWithBackgroundColor(6, 8, "'6 - 9", "H6", "H6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter);
        //        excell_app.AddHeaderDataWithBackgroundColor(6, 9, "'10 - 19", "I6", "I6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter);
        //        excell_app.AddHeaderData(6, 10, "20 - 49", "J6", "J6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(6, 11, "50 - 99", "K6", "K6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(6, 12, "100 - 249", "L6", "L6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(6, 13, "250 - 499", "M6", "M6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(6, 14, "500+", "N6", "N6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        //------------------------------------------------------------------------------------------------------------------------\\

        //        string categoryName = string.Empty;
        //        // int row = 7;

        //        DistributorPatternPriceLevelCostViewBO cost = new DistributorPatternPriceLevelCostViewBO();
        //        DistributorNullPatternPriceLevelCostViewBO nullCost = new DistributorNullPatternPriceLevelCostViewBO();
        //        List<DistributorPatternPriceLevelCostViewBO> lstCost = null;
        //        List<DistributorNullPatternPriceLevelCostViewBO> lstNullCost = null;

        //        List<int> indicoPrice = new List<int>();
        //        foreach (ExcelPriceLevelCostViewBO o in lstpr)
        //        {
        //            if (distributor == 0)
        //            {
        //                nullCost.Price = o.PriceID;
        //                lstNullCost = nullCost.SearchObjects();
        //            }
        //            else
        //            {
        //                cost.Price = o.PriceID;
        //                cost.Distributor = distributor;
        //                lstCost = cost.SearchObjects();
        //            }

        //            if (categoryName == string.Empty || categoryName != o.SportsCategory)
        //            {
        //                excell_app.AddData(row, 1, "", "A" + row, "A" + row, null, Excel.XlHAlign.xlHAlignLeft);
        //                categoryName = o.SportsCategory;

        //                row++;
        //            }
        //            excell_app.AddData(row, 1, o.SportsCategory, "A" + row, "A" + row, null, Excel.XlHAlign.xlHAlignLeft);
        //            excell_app.AddData(row, 2, o.OtherCategories, "B" + row, "B" + row, null, Excel.XlHAlign.xlHAlignLeft);
        //            excell_app.AddData(row, 3, "'" + o.Number, "C" + row, "C" + row, "@", Excel.XlHAlign.xlHAlignLeft);
        //            excell_app.AddData(row, 4, (o.ItemSubCategoris != null) ? o.ItemSubCategoris.ToUpper() : string.Empty, "D" + row, "D" + row, null, Excel.XlHAlign.xlHAlignLeft);
        //            excell_app.AddData(row, 5, o.NickName.ToUpper(), "E" + row, "E" + row, null, Excel.XlHAlign.xlHAlignLeft);
        //            excell_app.AddData(row, 6, o.FabricCodenNickName.ToUpper(), "F" + row, "F" + row, null, Excel.XlHAlign.xlHAlignLeft);

        //            if (distributor != 0)
        //            {

        //                decimal indicoCIFMarkup0 = (lstCost[0].EditedCIFPrice != null && lstCost[0].EditedCIFPrice.Value > 0) ? Math.Round(100 - ((lstCost[0].IndimanCost.Value * 100) / lstCost[0].EditedCIFPrice.Value), 2) : lstCost[0].Markup.Value;
        //                decimal EditedFOBPrice0 = (lstCost[0].EditedFOBPrice != null && lstCost[0].EditedFOBPrice.Value != 0) ? lstCost[0].EditedFOBPrice.Value : (lstCost[0].IndimanCost != 0) ? Math.Round(((lstCost[0].IndimanCost.Value - o.ConvertionFactor.Value)) / (1 - (indicoCIFMarkup0 / 100)), 2) : 0;

        //                decimal indicoCIFMarkup1 = (lstCost[1].EditedCIFPrice != null && lstCost[1].EditedCIFPrice.Value > 0) ? Math.Round(100 - ((lstCost[1].IndimanCost.Value * 100) / lstCost[1].EditedCIFPrice.Value), 2) : lstCost[1].Markup.Value;
        //                decimal EditedFOBPrice1 = (lstCost[1].EditedFOBPrice != null && lstCost[1].EditedFOBPrice.Value != 0) ? lstCost[1].EditedFOBPrice.Value : (lstCost[1].IndimanCost != 0) ? Math.Round(((lstCost[1].IndimanCost.Value - o.ConvertionFactor.Value)) / (1 - (indicoCIFMarkup1 / 100)), 2) : 0;

        //                decimal indicoCIFMarkup2 = (lstCost[2].EditedCIFPrice != null && lstCost[2].EditedCIFPrice.Value > 0) ? Math.Round(100 - ((lstCost[2].IndimanCost.Value * 100) / lstCost[2].EditedCIFPrice.Value), 2) : lstCost[2].Markup.Value;
        //                decimal EditedFOBPrice2 = (lstCost[2].EditedFOBPrice != null && lstCost[2].EditedFOBPrice.Value != 0) ? lstCost[2].EditedFOBPrice.Value : (lstCost[2].IndimanCost != 0) ? Math.Round(((lstCost[2].IndimanCost.Value - o.ConvertionFactor.Value)) / (1 - (indicoCIFMarkup2 / 100)), 2) : 0;

        //                decimal indicoCIFMarkup3 = (lstCost[3].EditedCIFPrice != null && lstCost[3].EditedCIFPrice.Value > 0) ? Math.Round(100 - ((lstCost[3].IndimanCost.Value * 100) / lstCost[3].EditedCIFPrice.Value), 2) : lstCost[3].Markup.Value;
        //                decimal EditedFOBPrice3 = (lstCost[3].EditedFOBPrice != null && lstCost[3].EditedFOBPrice.Value != 0) ? lstCost[3].EditedFOBPrice.Value : (lstCost[3].IndimanCost != 0) ? Math.Round(((lstCost[3].IndimanCost.Value - o.ConvertionFactor.Value)) / (1 - (indicoCIFMarkup3 / 100)), 2) : 0;

        //                decimal indicoCIFMarkup4 = (lstCost[4].EditedCIFPrice != null && lstCost[4].EditedCIFPrice.Value > 0) ? Math.Round(100 - ((lstCost[4].IndimanCost.Value * 100) / lstCost[4].EditedCIFPrice.Value), 2) : lstCost[4].Markup.Value;
        //                decimal EditedFOBPrice4 = (lstCost[4].EditedFOBPrice != null && lstCost[4].EditedFOBPrice.Value != 0) ? lstCost[4].EditedFOBPrice.Value : (lstCost[4].IndimanCost != 0) ? Math.Round(((lstCost[4].IndimanCost.Value - o.ConvertionFactor.Value)) / (1 - (indicoCIFMarkup4 / 100)), 2) : 0;

        //                decimal indicoCIFMarkup5 = (lstCost[5].EditedCIFPrice != null && lstCost[5].EditedCIFPrice.Value > 0) ? Math.Round(100 - ((lstCost[5].IndimanCost.Value * 100) / lstCost[5].EditedCIFPrice.Value), 2) : lstCost[5].Markup.Value;
        //                decimal EditedFOBPrice5 = (lstCost[5].EditedFOBPrice != null && lstCost[5].EditedFOBPrice.Value != 0) ? lstCost[5].EditedFOBPrice.Value : (lstCost[5].IndimanCost != 0) ? Math.Round(((lstCost[5].IndimanCost.Value - o.ConvertionFactor.Value)) / (1 - (indicoCIFMarkup5 / 100)), 2) : 0;

        //                decimal indicoCIFMarkup6 = (lstCost[6].EditedCIFPrice != null && lstCost[6].EditedCIFPrice.Value > 0) ? Math.Round(100 - ((lstCost[6].IndimanCost.Value * 100) / lstCost[6].EditedCIFPrice.Value), 2) : lstCost[6].Markup.Value;
        //                decimal EditedFOBPrice6 = (lstCost[6].EditedFOBPrice != null && lstCost[6].EditedFOBPrice.Value != 0) ? lstCost[6].EditedFOBPrice.Value : (lstCost[6].IndimanCost != 0) ? Math.Round(((lstCost[6].IndimanCost.Value - o.ConvertionFactor.Value)) / (1 - (indicoCIFMarkup6 / 100)), 2) : 0;

        //                decimal indicoCIFMarkup7 = (lstCost[7].EditedCIFPrice != null && lstCost[7].EditedCIFPrice.Value > 0) ? Math.Round(100 - ((lstCost[7].IndimanCost.Value * 100) / lstCost[7].EditedCIFPrice.Value), 2) : lstCost[7].Markup.Value;
        //                decimal EditedFOBPrice7 = (lstCost[7].EditedFOBPrice != null && lstCost[7].EditedFOBPrice.Value != 0) ? lstCost[7].EditedFOBPrice.Value : (lstCost[7].IndimanCost != 0) ? Math.Round(((lstCost[7].IndimanCost.Value - o.ConvertionFactor.Value)) / (1 - (indicoCIFMarkup7 / 100)), 2) : 0;


        //                /* decimal calCIFPrice = (decimal)((100 * lstCost[0].IndimanCost) / (100 - lstCost[0].Markup));
        //                 decimal calFOBPrice = (decimal)((100 * (lstCost[0].IndimanCost - o.ConvertionFactor)) / (100 - lstCost[0].Markup));*/

        //                excell_app.AddDataWithBackgroundColor(row, 7, (priceTerm == 1) ? ((!rbCalculatedPrice.Checked && lstCost[0].EditedCIFPrice != null) ? (lstCost[0].EditedCIFPrice.ToString()) : (((100 * lstCost[0].IndimanCost) / (100 - lstCost[0].Markup)).ToString()))
        //                    : ((!rbCalculatedPrice.Checked && lstCost[0].EditedFOBPrice != null) ? (EditedFOBPrice0.ToString()) : (((100 * (lstCost[0].IndimanCost - o.ConvertionFactor)) / (100 - lstCost[0].Markup)).ToString())), "G" + row, "G" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

        //                excell_app.AddDataWithBackgroundColor(row, 8, (priceTerm == 1) ? ((!rbCalculatedPrice.Checked && lstCost[1].EditedCIFPrice != null) ? (lstCost[1].EditedCIFPrice.ToString()) : (((100 * lstCost[1].IndimanCost) / (100 - lstCost[1].Markup)).ToString()))
        //                    : ((!rbCalculatedPrice.Checked && lstCost[1].EditedFOBPrice != null) ? (EditedFOBPrice1.ToString()) : (((100 * (lstCost[1].IndimanCost - o.ConvertionFactor)) / (100 - lstCost[1].Markup)).ToString())), "H" + row, "H" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

        //                excell_app.AddDataWithBackgroundColor(row, 9, (priceTerm == 1) ? ((!rbCalculatedPrice.Checked && lstCost[2].EditedCIFPrice != null) ? (lstCost[2].EditedCIFPrice.ToString()) : (((100 * lstCost[2].IndimanCost) / (100 - lstCost[2].Markup)).ToString()))
        //                    : ((!rbCalculatedPrice.Checked && lstCost[2].EditedFOBPrice != null) ? (EditedFOBPrice2.ToString()) : (((100 * (lstCost[2].IndimanCost - o.ConvertionFactor)) / (100 - lstCost[2].Markup)).ToString())), "I" + row, "I" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

        //                excell_app.AddData(row, 10, (priceTerm == 1) ? ((!rbCalculatedPrice.Checked && lstCost[3].EditedCIFPrice != null) ? (lstCost[3].EditedCIFPrice.ToString()) : (((100 * lstCost[3].IndimanCost) / (100 - lstCost[3].Markup)).ToString()))
        //                    : ((!rbCalculatedPrice.Checked && lstCost[3].EditedFOBPrice != null) ? (EditedFOBPrice3.ToString()) : (((100 * (lstCost[3].IndimanCost - o.ConvertionFactor)) / (100 - lstCost[3].Markup)).ToString())), "J" + row, "J" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

        //                excell_app.AddData(row, 11, (priceTerm == 1) ? ((!rbCalculatedPrice.Checked && lstCost[4].EditedCIFPrice != null) ? (lstCost[4].EditedCIFPrice.ToString()) : (((100 * lstCost[4].IndimanCost) / (100 - lstCost[4].Markup)).ToString()))
        //                    : ((!rbCalculatedPrice.Checked && lstCost[4].EditedFOBPrice != null) ? (EditedFOBPrice4.ToString()) : (((100 * (lstCost[4].IndimanCost - o.ConvertionFactor)) / (100 - lstCost[4].Markup)).ToString())), "K" + row, "K" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

        //                excell_app.AddData(row, 12, (priceTerm == 1) ? ((!rbCalculatedPrice.Checked && lstCost[5].EditedCIFPrice != null) ? (lstCost[5].EditedCIFPrice.ToString()) : (((100 * lstCost[5].IndimanCost) / (100 - lstCost[5].Markup)).ToString()))
        //                    : ((!rbCalculatedPrice.Checked && lstCost[5].EditedFOBPrice != null) ? (EditedFOBPrice5.ToString()) : (((100 * (lstCost[5].IndimanCost - o.ConvertionFactor)) / (100 - lstCost[5].Markup)).ToString())), "L" + row, "L" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

        //                excell_app.AddData(row, 13, (priceTerm == 1) ? ((!rbCalculatedPrice.Checked && lstCost[6].EditedCIFPrice != null) ? (lstCost[6].EditedCIFPrice.ToString()) : (((100 * lstCost[6].IndimanCost) / (100 - lstCost[6].Markup)).ToString()))
        //                    : ((!rbCalculatedPrice.Checked && lstCost[6].EditedFOBPrice != null) ? (EditedFOBPrice6.ToString()) : (((100 * (lstCost[6].IndimanCost - o.ConvertionFactor)) / (100 - lstCost[6].Markup)).ToString())), "M" + row, "M" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

        //                excell_app.AddData(row, 14, (priceTerm == 1) ? ((!rbCalculatedPrice.Checked && lstCost[7].EditedCIFPrice != null) ? (lstCost[7].EditedCIFPrice.ToString()) : (((100 * lstCost[7].IndimanCost) / (100 - lstCost[7].Markup)).ToString()))
        //                    : ((!rbCalculatedPrice.Checked && lstCost[7].EditedFOBPrice != null) ? (EditedFOBPrice7.ToString()) : (((100 * (lstCost[7].IndimanCost - o.ConvertionFactor)) / (100 - lstCost[7].Markup)).ToString())), "N" + row, "N" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

        //            }
        //            else
        //            {
        //                decimal indicoCIFMarkup0 = (lstNullCost[0].EditedCIFPrice != null && lstNullCost[0].EditedCIFPrice.Value > 0) ? Math.Round(100 - ((lstNullCost[0].IndimanCost.Value * 100) / lstNullCost[0].EditedCIFPrice.Value), 2) : lstNullCost[0].Markup.Value;
        //                decimal EditedFOBPrice0 = (lstNullCost[0].EditedFOBPrice != null && lstNullCost[0].EditedFOBPrice.Value != 0) ? lstNullCost[0].EditedFOBPrice.Value : (lstNullCost[0].IndimanCost != 0) ? Math.Round(((lstNullCost[0].IndimanCost.Value - o.ConvertionFactor.Value)) / (1 - (indicoCIFMarkup0 / 100)), 2) : 0;

        //                decimal indicoCIFMarkup1 = (lstNullCost[1].EditedCIFPrice != null && lstNullCost[1].EditedCIFPrice.Value > 0) ? Math.Round(100 - ((lstNullCost[1].IndimanCost.Value * 100) / lstNullCost[1].EditedCIFPrice.Value), 2) : lstNullCost[1].Markup.Value;
        //                decimal EditedFOBPrice1 = (lstNullCost[1].EditedFOBPrice != null && lstNullCost[1].EditedFOBPrice.Value != 0) ? lstNullCost[1].EditedFOBPrice.Value : (lstNullCost[1].IndimanCost != 0) ? Math.Round(((lstNullCost[1].IndimanCost.Value - o.ConvertionFactor.Value)) / (1 - (indicoCIFMarkup1 / 100)), 2) : 0;

        //                decimal indicoCIFMarkup2 = (lstNullCost[2].EditedCIFPrice != null && lstNullCost[2].EditedCIFPrice.Value > 0) ? Math.Round(100 - ((lstNullCost[2].IndimanCost.Value * 100) / lstNullCost[2].EditedCIFPrice.Value), 2) : lstNullCost[2].Markup.Value;
        //                decimal EditedFOBPrice2 = (lstNullCost[2].EditedFOBPrice != null && lstNullCost[2].EditedFOBPrice.Value != 0) ? lstNullCost[2].EditedFOBPrice.Value : (lstNullCost[2].IndimanCost != 0) ? Math.Round(((lstNullCost[2].IndimanCost.Value - o.ConvertionFactor.Value)) / (1 - (indicoCIFMarkup2 / 100)), 2) : 0;

        //                decimal indicoCIFMarkup3 = (lstNullCost[3].EditedCIFPrice != null && lstNullCost[3].EditedCIFPrice.Value > 0) ? Math.Round(100 - ((lstNullCost[3].IndimanCost.Value * 100) / lstNullCost[3].EditedCIFPrice.Value), 2) : lstNullCost[3].Markup.Value;
        //                decimal EditedFOBPrice3 = (lstNullCost[3].EditedFOBPrice != null && lstNullCost[3].EditedFOBPrice.Value != 0) ? lstNullCost[3].EditedFOBPrice.Value : (lstNullCost[3].IndimanCost != 0) ? Math.Round(((lstNullCost[3].IndimanCost.Value - o.ConvertionFactor.Value)) / (1 - (indicoCIFMarkup3 / 100)), 2) : 0;

        //                decimal indicoCIFMarkup4 = (lstNullCost[4].EditedCIFPrice != null && lstNullCost[4].EditedCIFPrice.Value > 0) ? Math.Round(100 - ((lstNullCost[4].IndimanCost.Value * 100) / lstNullCost[4].EditedCIFPrice.Value), 2) : lstNullCost[4].Markup.Value;
        //                decimal EditedFOBPrice4 = (lstNullCost[4].EditedFOBPrice != null && lstNullCost[4].EditedFOBPrice.Value != 0) ? lstNullCost[4].EditedFOBPrice.Value : (lstNullCost[4].IndimanCost != 0) ? Math.Round(((lstNullCost[4].IndimanCost.Value - o.ConvertionFactor.Value)) / (1 - (indicoCIFMarkup4 / 100)), 2) : 0;

        //                decimal indicoCIFMarkup5 = (lstNullCost[5].EditedCIFPrice != null && lstNullCost[5].EditedCIFPrice.Value > 0) ? Math.Round(100 - ((lstNullCost[5].IndimanCost.Value * 100) / lstNullCost[5].EditedCIFPrice.Value), 2) : lstNullCost[5].Markup.Value;
        //                decimal EditedFOBPrice5 = (lstNullCost[5].EditedFOBPrice != null && lstNullCost[5].EditedFOBPrice.Value != 0) ? lstNullCost[5].EditedFOBPrice.Value : (lstNullCost[5].IndimanCost != 0) ? Math.Round(((lstNullCost[5].IndimanCost.Value - o.ConvertionFactor.Value)) / (1 - (indicoCIFMarkup5 / 100)), 2) : 0;

        //                decimal indicoCIFMarkup6 = (lstNullCost[6].EditedCIFPrice != null && lstNullCost[6].EditedCIFPrice.Value > 0) ? Math.Round(100 - ((lstNullCost[6].IndimanCost.Value * 100) / lstNullCost[6].EditedCIFPrice.Value), 2) : lstNullCost[6].Markup.Value;
        //                decimal EditedFOBPrice6 = (lstNullCost[6].EditedFOBPrice != null && lstNullCost[6].EditedFOBPrice.Value != 0) ? lstNullCost[6].EditedFOBPrice.Value : (lstNullCost[6].IndimanCost != 0) ? Math.Round(((lstNullCost[6].IndimanCost.Value - o.ConvertionFactor.Value)) / (1 - (indicoCIFMarkup6 / 100)), 2) : 0;

        //                decimal indicoCIFMarkup7 = (lstNullCost[7].EditedCIFPrice != null && lstNullCost[7].EditedCIFPrice.Value > 0) ? Math.Round(100 - ((lstNullCost[7].IndimanCost.Value * 100) / lstNullCost[7].EditedCIFPrice.Value), 2) : lstNullCost[7].Markup.Value;
        //                decimal EditedFOBPrice7 = (lstNullCost[7].EditedFOBPrice != null && lstNullCost[7].EditedFOBPrice.Value != 0) ? lstNullCost[7].EditedFOBPrice.Value : (lstNullCost[7].IndimanCost != 0) ? Math.Round(((lstNullCost[7].IndimanCost.Value - o.ConvertionFactor.Value)) / (1 - (indicoCIFMarkup7 / 100)), 2) : 0;


        //                /*decimal calCIFPrice = (decimal)((100 * lstNullCost[0].IndimanCost) / (100 - lstNullCost[0].Markup));
        //                 decimal calFOBPrice = (decimal)((100 * (lstNullCost[0].IndimanCost - o.ConvertionFactor)) / (100 - lstNullCost[0].Markup));*/

        //                excell_app.AddDataWithBackgroundColor(row, 7, (priceTerm == 1) ? ((!rbCalculatedPrice.Checked && lstNullCost[0].EditedCIFPrice != null) ? (lstNullCost[0].EditedCIFPrice.ToString()) : (((100 * lstNullCost[0].IndimanCost) / (100 - lstNullCost[0].Markup)).ToString()))
        //                    : ((!rbCalculatedPrice.Checked && lstNullCost[0].EditedFOBPrice != null) ? EditedFOBPrice0.ToString() : (((100 * (lstNullCost[0].IndimanCost - o.ConvertionFactor)) / (100 - lstNullCost[0].Markup)).ToString())), "G" + row, "G" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

        //                excell_app.AddDataWithBackgroundColor(row, 8, (priceTerm == 1) ? ((!rbCalculatedPrice.Checked && lstNullCost[1].EditedCIFPrice != null) ? (lstNullCost[1].EditedCIFPrice.ToString()) : (((100 * lstNullCost[1].IndimanCost) / (100 - lstNullCost[1].Markup)).ToString()))
        //                    : ((!rbCalculatedPrice.Checked && lstNullCost[1].EditedFOBPrice != null) ? EditedFOBPrice1.ToString() : (((100 * (lstNullCost[1].IndimanCost - o.ConvertionFactor)) / (100 - lstNullCost[1].Markup)).ToString())), "H" + row, "H" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

        //                excell_app.AddDataWithBackgroundColor(row, 9, (priceTerm == 1) ? ((!rbCalculatedPrice.Checked && lstNullCost[2].EditedCIFPrice != null) ? (lstNullCost[2].EditedCIFPrice.ToString()) : (((100 * lstNullCost[2].IndimanCost) / (100 - lstNullCost[2].Markup)).ToString()))
        //                    : ((!rbCalculatedPrice.Checked && lstNullCost[2].EditedFOBPrice != null) ? EditedFOBPrice2.ToString() : (((100 * (lstNullCost[2].IndimanCost - o.ConvertionFactor)) / (100 - lstNullCost[2].Markup)).ToString())), "I" + row, "I" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

        //                excell_app.AddData(row, 10, (priceTerm == 1) ? ((!rbCalculatedPrice.Checked && lstNullCost[3].EditedCIFPrice != null) ? (lstNullCost[3].EditedCIFPrice.ToString()) : (((100 * lstNullCost[3].IndimanCost) / (100 - lstNullCost[3].Markup)).ToString()))
        //                    : ((!rbCalculatedPrice.Checked && lstNullCost[3].EditedFOBPrice != null) ? EditedFOBPrice3.ToString() : (((100 * (lstNullCost[3].IndimanCost - o.ConvertionFactor)) / (100 - lstNullCost[3].Markup)).ToString())), "J" + row, "J" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

        //                excell_app.AddData(row, 11, (priceTerm == 1) ? ((!rbCalculatedPrice.Checked && lstNullCost[4].EditedCIFPrice != null) ? (lstNullCost[4].EditedCIFPrice.ToString()) : (((100 * lstNullCost[4].IndimanCost) / (100 - lstNullCost[4].Markup)).ToString()))
        //                    : ((!rbCalculatedPrice.Checked && lstNullCost[4].EditedFOBPrice != null) ? EditedFOBPrice4.ToString() : (((100 * (lstNullCost[4].IndimanCost - o.ConvertionFactor)) / (100 - lstNullCost[4].Markup)).ToString())), "K" + row, "K" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

        //                excell_app.AddData(row, 12, (priceTerm == 1) ? ((!rbCalculatedPrice.Checked && lstNullCost[5].EditedCIFPrice != null) ? (lstNullCost[5].EditedCIFPrice.ToString()) : (((100 * lstNullCost[5].IndimanCost) / (100 - lstNullCost[5].Markup)).ToString()))
        //                    : ((!rbCalculatedPrice.Checked && lstNullCost[5].EditedFOBPrice != null) ? EditedFOBPrice5.ToString() : (((100 * (lstNullCost[5].IndimanCost - o.ConvertionFactor)) / (100 - lstNullCost[5].Markup)).ToString())), "L" + row, "L" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

        //                excell_app.AddData(row, 13, (priceTerm == 1) ? ((!rbCalculatedPrice.Checked && lstNullCost[6].EditedCIFPrice != null) ? (lstNullCost[6].EditedCIFPrice.ToString()) : (((100 * lstNullCost[6].IndimanCost) / (100 - lstNullCost[6].Markup)).ToString()))
        //                    : ((!rbCalculatedPrice.Checked && lstNullCost[6].EditedFOBPrice != null) ? EditedFOBPrice6.ToString() : (((100 * (lstNullCost[6].IndimanCost - o.ConvertionFactor)) / (100 - lstNullCost[6].Markup)).ToString())), "M" + row, "M" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

        //                excell_app.AddData(row, 14, (priceTerm == 1) ? ((!rbCalculatedPrice.Checked && lstNullCost[7].EditedCIFPrice != null) ? (lstNullCost[7].EditedCIFPrice.ToString()) : (((100 * lstNullCost[7].IndimanCost) / (100 - lstNullCost[7].Markup)).ToString()))
        //                    : ((!rbCalculatedPrice.Checked && lstNullCost[7].EditedFOBPrice != null) ? EditedFOBPrice7.ToString() : (((100 * (lstNullCost[7].IndimanCost - o.ConvertionFactor)) / (100 - lstNullCost[7].Markup)).ToString())), "N" + row, "N" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);
        //            }
        //            row++;
        //            i++;

        //            //xlProgress = Math.Round(((double.Parse("100") / double.Parse(lstpr.Count.ToString())) * i), 0);

        //            // Writing progress in text file.
        //            /* string lines = xlProgress.ToString();
        //             System.IO.StreamWriter file = new System.IO.StreamWriter(textFilePath, false);
        //             file.WriteLine(lines);
        //             file.Close();*/
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        // Log the error
        //        IndicoLogging.log.Error("Error occured while Generation Excel.", ex);
        //    }
        //    finally
        //    {
        //        // Set AutoFilter colums
        //        excell_app.AutoFilter(row);
        //        // Save & Close the Excel Document
        //        excell_app.CloseDocument(filePath);

        //        // release the lock
        //        IndicoPage.RWLock.ReleaseWriterLock();


        //    }
        //}

        //private void GenerateLabelExcel(string filePath, int priceTerm, string priceTermName)
        //{
        //    // get a write lock on scCacheKeys
        //    IndicoPage.RWLock.AcquireWriterLock(Timeout.Infinite);

        //    // Excel
        //    double xlProgress = 0;
        //    int i = 0;
        //    string creativeDesign = string.Empty;
        //    string studioDesign = string.Empty;
        //    string thirdPartyDesign = string.Empty;
        //    string position1 = string.Empty;
        //    string position2 = string.Empty;
        //    string position3 = string.Empty;
        //    string priceValidDate = string.Empty;
        //    int row = 7;
        //    DefaultValuesPriceListBO objDefaultPriceList = new DefaultValuesPriceListBO().SearchObjects().SingleOrDefault();
        //    /* string textFilePath = IndicoConfiguration.AppConfiguration.PathToDataFolder + @"\Temp\progress_" + 1 + ".txt";
        //     if (File.Exists(textFilePath))
        //     {
        //         File.Delete(textFilePath);
        //     }*/

        //    CreateExcelDocument excell_app = new CreateExcelDocument(true);

        //    #region checkDesign

        //    if (checkCreativeDesign.Checked)
        //    {
        //        if (!string.IsNullOrEmpty(txtCreativeDesign.Text) && this.txtCreativeDesign.Text != objDefaultPriceList.CreativeDesign.ToString())
        //        {
        //            creativeDesign = "Creative Design Set Up Fee: $" + txtCreativeDesign.Text + " + GST per Job";
        //        }
        //        else
        //        {
        //            creativeDesign = "Creative Design Set Up Fee: $" + objDefaultPriceList.CreativeDesign.ToString() + " + GST per Job";
        //        }
        //    }
        //    if (checkStudioDesign.Checked)
        //    {
        //        if (!string.IsNullOrEmpty(txtStudioDesign.Text) && this.txtStudioDesign.Text != objDefaultPriceList.StudioDesign.ToString())
        //        {
        //            studioDesign = "Studio Design Set Up Fee: $" + txtStudioDesign.Text + " + GST per Job";
        //        }
        //        else
        //        {
        //            studioDesign = "Studio Design Set Up Fee: $" + objDefaultPriceList.StudioDesign.ToString() + " + GST per Job";
        //        }
        //    }
        //    if (checkThirdPartyDesign.Checked)
        //    {
        //        if (!string.IsNullOrEmpty(txtThirdPartyDesign.Text) && this.txtThirdPartyDesign.Text != objDefaultPriceList.ThirdPartyDesign.ToString())
        //        {
        //            thirdPartyDesign = "Third Party Design Set Up Fee: $" + txtThirdPartyDesign.Text + " + GST per Job";
        //        }
        //        else
        //        {
        //            thirdPartyDesign = "Third Party Design Set Up Fee: $" + objDefaultPriceList.ThirdPartyDesign.ToString() + " + GST per Job";
        //        }
        //    }

        //    #endregion

        //    #region checkPsotion

        //    if (checkPositionOne.Checked)
        //    {
        //        if (!string.IsNullOrEmpty(txtPositionOne.Text) && this.txtPositionOne.Text != objDefaultPriceList.Position1.ToString())
        //        {
        //            position1 = "1 x Position @ $" + txtPositionOne.Text + " - eg name on left chest";
        //        }
        //        else
        //        {
        //            position1 = "1 x Position @ $" + objDefaultPriceList.Position1.ToString() + " - eg name on left chest";
        //        }
        //    }
        //    if (checkPositionTwo.Checked)
        //    {
        //        if (!string.IsNullOrEmpty(txtPositionTwo.Text) && this.txtPositionTwo.Text != objDefaultPriceList.Position2.ToString())
        //        {
        //            position2 = "2 x Positions @ $" + txtPositionTwo.Text + " - eg names on left chest and upper back";
        //        }
        //        else
        //        {
        //            position2 = "2 x Positions @ $" + objDefaultPriceList.Position2.ToString() + " - eg names on left chest and upper back";
        //        }
        //    }
        //    if (checkPositionThree.Checked)
        //    {
        //        if (!string.IsNullOrEmpty(txtPositionThree.Text) && this.txtPositionThree.Text != objDefaultPriceList.Position3.ToString())
        //        {
        //            position3 = "3 x Positions @ $" + txtPositionThree.Text + " - eg names on left chest, upper back and number on lower back";
        //        }
        //        else
        //        {
        //            position3 = "3 x Positions @ $" + objDefaultPriceList.Position3.ToString() + " - eg names on left chest, upper back and number on lower back";
        //        }
        //    }
        //    #endregion



        //    try
        //    {
        //        int label = int.Parse(this.ddlLabelExcel.SelectedValue);

        //        String excelType = string.Empty;
        //        PriceBO objPrice = new PriceBO();
        //        ExcelPriceLevelCostViewBO excel = new ExcelPriceLevelCostViewBO();
        //        List<ExcelPriceLevelCostViewBO> lstpr = (from o in excel.SearchObjects()
        //                                                 orderby o.SportsCategory
        //                                                 select o).ToList();

        //        // first row
        //        excell_app.AddHeaderData(1, 1, "" + this.ddlLabelExcel.SelectedItem.Text.ToUpper() + " - " + priceTermName + " PRICE LIST ALL PLUS GST PLUS LOCAL FREIGHT EX-ADELAIDE", "A1", "D1", true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignLeft, "General");
        //        // Second row
        //        excell_app.AddHeaderData(2, 1, "INDICO PTY LTD", "A2", "B2", true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignLeft, "General");
        //        excell_app.AddHeaderData(2, 3, "Published Date: " + DateTime.Now.ToString("dd MMMM yyyy") + "", "C2", "D2", true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignLeft, "General");
        //        excell_app.AddHeaderData(2, 5, "" + creativeDesign + "     " + studioDesign + "     " + thirdPartyDesign + "", "E2", "F2", true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignLeft, "General");
        //        excell_app.AddHeaderData(2, 9, "QUANTITY", "G2", "N2", true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        // Third row
        //        // excell_app.AddHeaderData(3, 3, priceValidDate, "C5", "D5", true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignLeft, "dd MMMM yyyy");
        //        // Fourth row
        //        excell_app.AddHeaderData(4, 1, "Individual Names & Numbers are charged as follows:     " + position1 + "     " + position2 + "    " + position3 + " ", "A4", "F4", true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignLeft, "General");
        //        excell_app.AddHeaderData(4, 9, "All re-orders under 20 units wll have the benefit of receiving the 20 unit price", "G4", "N4", true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        // Column headers
        //        excell_app.AddHeaderData(6, 1, "SPORTS CATEGORY", "A6", "A6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(6, 2, "OTHER CATEGORIES", "B6", "B6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(6, 3, "PATTERN", "C6", "C6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(6, 4, "ITEM SUB CATEGORY", "D6", "D6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(6, 5, "DESCRIPTION", "E6", "E6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(6, 6, "FABRIC", "F6", "F6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderDataWithBackgroundColor(6, 7, "'1-5", "G6", "G6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter);
        //        excell_app.AddHeaderDataWithBackgroundColor(6, 8, "'6 - 9", "H6", "H6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter);
        //        excell_app.AddHeaderDataWithBackgroundColor(6, 9, "'10 - 19", "I6", "I6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter);
        //        excell_app.AddHeaderData(6, 10, "20 - 49", "J6", "J6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(6, 11, "50 - 99", "K6", "K6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(6, 12, "100 - 249", "L6", "L6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(6, 13, "250 - 499", "M6", "M6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(6, 14, "500+", "N6", "N6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        //------------------------------------------------------------------------------------------------------------------------\\

        //        string categoryName = string.Empty;
        //        // int row = 7;

        //        LabelPatternPriceLevelCostViewBO cost = new LabelPatternPriceLevelCostViewBO();
        //        List<LabelPatternPriceLevelCostViewBO> lstCost = null;


        //        List<int> indicoPrice = new List<int>();
        //        foreach (ExcelPriceLevelCostViewBO o in lstpr)
        //        {

        //            cost.Price = o.PriceID;
        //            cost.Label = label;
        //            lstCost = cost.SearchObjects();


        //            if (categoryName == string.Empty || categoryName != o.SportsCategory)
        //            {
        //                excell_app.AddData(row, 1, "", "A" + row, "A" + row, null, Excel.XlHAlign.xlHAlignLeft);
        //                categoryName = o.SportsCategory;

        //                row++;
        //            }
        //            excell_app.AddData(row, 1, o.SportsCategory, "A" + row, "A" + row, null, Excel.XlHAlign.xlHAlignLeft);
        //            excell_app.AddData(row, 2, o.OtherCategories, "B" + row, "B" + row, null, Excel.XlHAlign.xlHAlignLeft);
        //            excell_app.AddData(row, 3, "'" + o.Number, "C" + row, "C" + row, "@", Excel.XlHAlign.xlHAlignLeft);
        //            excell_app.AddData(row, 4, (o.ItemSubCategoris != null) ? o.ItemSubCategoris.ToUpper() : string.Empty, "D" + row, "D" + row, null, Excel.XlHAlign.xlHAlignLeft);
        //            excell_app.AddData(row, 5, o.NickName.ToUpper(), "E" + row, "E" + row, null, Excel.XlHAlign.xlHAlignLeft);
        //            excell_app.AddData(row, 6, o.FabricCodenNickName.ToUpper(), "F" + row, "F" + row, null, Excel.XlHAlign.xlHAlignLeft);

        //            if (i == 433)
        //            {

        //            }

        //            decimal indicoCIFMarkup0 = (lstCost[0].EditedCIFPrice != null && lstCost[0].EditedCIFPrice != 0) ? Math.Round(100 - ((lstCost[0].IndimanCost.Value * 100) / lstCost[0].EditedCIFPrice.Value), 2) : lstCost[0].Markup.Value;
        //            decimal EditedFOBPrice0 = (lstCost[0].EditedFOBPrice != null && lstCost[0].EditedFOBPrice.Value != 0) ? lstCost[0].EditedFOBPrice.Value : (lstCost[0].IndimanCost != 0) ? Math.Round(((lstCost[0].IndimanCost.Value - o.ConvertionFactor.Value)) / (1 - (indicoCIFMarkup0 / 100)), 2) : 0;

        //            decimal indicoCIFMarkup1 = (lstCost[1].EditedCIFPrice != null && lstCost[1].EditedCIFPrice != 0) ? Math.Round(100 - ((lstCost[1].IndimanCost.Value * 100) / lstCost[1].EditedCIFPrice.Value), 2) : lstCost[1].Markup.Value;
        //            decimal EditedFOBPrice1 = (lstCost[1].EditedFOBPrice != null && lstCost[1].EditedFOBPrice.Value != 0) ? lstCost[1].EditedFOBPrice.Value : (lstCost[1].IndimanCost != 0) ? Math.Round(((lstCost[1].IndimanCost.Value - o.ConvertionFactor.Value)) / (1 - (indicoCIFMarkup1 / 100)), 2) : 0;

        //            decimal indicoCIFMarkup2 = (lstCost[2].EditedCIFPrice != null && lstCost[2].EditedCIFPrice != 0) ? Math.Round(100 - ((lstCost[2].IndimanCost.Value * 100) / lstCost[2].EditedCIFPrice.Value), 2) : lstCost[2].Markup.Value;
        //            decimal EditedFOBPrice2 = (lstCost[2].EditedFOBPrice != null && lstCost[2].EditedFOBPrice.Value != 0) ? lstCost[2].EditedFOBPrice.Value : (lstCost[2].IndimanCost != 0) ? Math.Round(((lstCost[2].IndimanCost.Value - o.ConvertionFactor.Value)) / (1 - (indicoCIFMarkup2 / 100)), 2) : 0;

        //            decimal indicoCIFMarkup3 = (lstCost[3].EditedCIFPrice != null && lstCost[3].EditedCIFPrice != 0) ? Math.Round(100 - ((lstCost[3].IndimanCost.Value * 100) / lstCost[3].EditedCIFPrice.Value), 2) : lstCost[3].Markup.Value;
        //            decimal EditedFOBPrice3 = (lstCost[3].EditedFOBPrice != null && lstCost[3].EditedFOBPrice.Value != 0) ? lstCost[3].EditedFOBPrice.Value : (lstCost[3].IndimanCost != 0) ? Math.Round(((lstCost[3].IndimanCost.Value - o.ConvertionFactor.Value)) / (1 - (indicoCIFMarkup3 / 100)), 2) : 0;

        //            decimal indicoCIFMarkup4 = (lstCost[4].EditedCIFPrice != null && lstCost[4].EditedCIFPrice != 0) ? Math.Round(100 - ((lstCost[4].IndimanCost.Value * 100) / lstCost[4].EditedCIFPrice.Value), 2) : lstCost[4].Markup.Value;
        //            decimal EditedFOBPrice4 = (lstCost[4].EditedFOBPrice != null && lstCost[4].EditedFOBPrice.Value != 0) ? lstCost[4].EditedFOBPrice.Value : (lstCost[4].IndimanCost != 0) ? Math.Round(((lstCost[4].IndimanCost.Value - o.ConvertionFactor.Value)) / (1 - (indicoCIFMarkup4 / 100)), 2) : 0;

        //            decimal indicoCIFMarkup5 = (lstCost[5].EditedCIFPrice != null && lstCost[5].EditedCIFPrice != 0) ? Math.Round(100 - ((lstCost[5].IndimanCost.Value * 100) / lstCost[5].EditedCIFPrice.Value), 2) : lstCost[5].Markup.Value;
        //            decimal EditedFOBPrice5 = (lstCost[5].EditedFOBPrice != null && lstCost[5].EditedFOBPrice.Value != 0) ? lstCost[5].EditedFOBPrice.Value : (lstCost[5].IndimanCost != 0) ? Math.Round(((lstCost[5].IndimanCost.Value - o.ConvertionFactor.Value)) / (1 - (indicoCIFMarkup5 / 100)), 2) : 0;

        //            decimal indicoCIFMarkup6 = (lstCost[6].EditedCIFPrice != null && lstCost[6].EditedCIFPrice != 0) ? Math.Round(100 - ((lstCost[6].IndimanCost.Value * 100) / lstCost[6].EditedCIFPrice.Value), 2) : lstCost[6].Markup.Value;
        //            decimal EditedFOBPrice6 = (lstCost[6].EditedFOBPrice != null && lstCost[6].EditedFOBPrice.Value != 0) ? lstCost[6].EditedFOBPrice.Value : (lstCost[6].IndimanCost != 0) ? Math.Round(((lstCost[6].IndimanCost.Value - o.ConvertionFactor.Value)) / (1 - (indicoCIFMarkup6 / 100)), 2) : 0;

        //            decimal indicoCIFMarkup7 = (lstCost[7].EditedCIFPrice != null && lstCost[7].EditedCIFPrice != 0) ? Math.Round(100 - ((lstCost[7].IndimanCost.Value * 100) / lstCost[7].EditedCIFPrice.Value), 2) : lstCost[7].Markup.Value;
        //            decimal EditedFOBPrice7 = (lstCost[7].EditedFOBPrice != null && lstCost[7].EditedFOBPrice.Value != 0) ? lstCost[7].EditedFOBPrice.Value : (lstCost[7].IndimanCost != 0) ? Math.Round(((lstCost[7].IndimanCost.Value - o.ConvertionFactor.Value)) / (1 - (indicoCIFMarkup7 / 100)), 2) : 0;


        //            decimal calCIFPrice = (decimal)((100 * lstCost[0].IndimanCost) / (100 - lstCost[0].Markup));
        //            decimal calFOBPrice = (decimal)((100 * (lstCost[0].IndimanCost - o.ConvertionFactor)) / (100 - lstCost[0].Markup));

        //            excell_app.AddDataWithBackgroundColor(row, 7, (priceTerm == 1) ? ((!rbCalculatedPrice.Checked && lstCost[0].EditedCIFPrice != null) ? (lstCost[0].EditedCIFPrice.ToString()) : (((100 * lstCost[0].IndimanCost) / (100 - lstCost[0].Markup)).ToString()))
        //                : ((!rbCalculatedPrice.Checked && lstCost[0].EditedFOBPrice != null) ? (EditedFOBPrice0.ToString()) : (((100 * (lstCost[0].IndimanCost - o.ConvertionFactor)) / (100 - lstCost[0].Markup)).ToString())), "G" + row, "G" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

        //            excell_app.AddDataWithBackgroundColor(row, 8, (priceTerm == 1) ? ((!rbCalculatedPrice.Checked && lstCost[1].EditedCIFPrice != null) ? (lstCost[1].EditedCIFPrice.ToString()) : (((100 * lstCost[1].IndimanCost) / (100 - lstCost[1].Markup)).ToString()))
        //                : ((!rbCalculatedPrice.Checked && lstCost[1].EditedFOBPrice != null) ? (EditedFOBPrice1.ToString()) : (((100 * (lstCost[1].IndimanCost - o.ConvertionFactor)) / (100 - lstCost[1].Markup)).ToString())), "H" + row, "H" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

        //            excell_app.AddDataWithBackgroundColor(row, 9, (priceTerm == 1) ? ((!rbCalculatedPrice.Checked && lstCost[2].EditedCIFPrice != null) ? (lstCost[2].EditedCIFPrice.ToString()) : (((100 * lstCost[2].IndimanCost) / (100 - lstCost[2].Markup)).ToString()))
        //                : ((!rbCalculatedPrice.Checked && lstCost[2].EditedFOBPrice != null) ? (EditedFOBPrice2.ToString()) : (((100 * (lstCost[2].IndimanCost - o.ConvertionFactor)) / (100 - lstCost[2].Markup)).ToString())), "I" + row, "I" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

        //            excell_app.AddData(row, 10, (priceTerm == 1) ? ((!rbCalculatedPrice.Checked && lstCost[3].EditedCIFPrice != null) ? (lstCost[3].EditedCIFPrice.ToString()) : (((100 * lstCost[3].IndimanCost) / (100 - lstCost[3].Markup)).ToString()))
        //                : ((!rbCalculatedPrice.Checked && lstCost[3].EditedFOBPrice != null) ? (EditedFOBPrice3.ToString()) : (((100 * (lstCost[3].IndimanCost - o.ConvertionFactor)) / (100 - lstCost[3].Markup)).ToString())), "J" + row, "J" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

        //            excell_app.AddData(row, 11, (priceTerm == 1) ? ((!rbCalculatedPrice.Checked && lstCost[4].EditedCIFPrice != null) ? (lstCost[4].EditedCIFPrice.ToString()) : (((100 * lstCost[4].IndimanCost) / (100 - lstCost[4].Markup)).ToString()))
        //                : ((!rbCalculatedPrice.Checked && lstCost[4].EditedFOBPrice != null) ? (EditedFOBPrice4.ToString()) : (((100 * (lstCost[4].IndimanCost - o.ConvertionFactor)) / (100 - lstCost[4].Markup)).ToString())), "K" + row, "K" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

        //            excell_app.AddData(row, 12, (priceTerm == 1) ? ((!rbCalculatedPrice.Checked && lstCost[5].EditedCIFPrice != null) ? (lstCost[5].EditedCIFPrice.ToString()) : (((100 * lstCost[5].IndimanCost) / (100 - lstCost[5].Markup)).ToString()))
        //                : ((!rbCalculatedPrice.Checked && lstCost[5].EditedFOBPrice != null) ? (EditedFOBPrice5.ToString()) : (((100 * (lstCost[5].IndimanCost - o.ConvertionFactor)) / (100 - lstCost[5].Markup)).ToString())), "L" + row, "L" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

        //            excell_app.AddData(row, 13, (priceTerm == 1) ? ((!rbCalculatedPrice.Checked && lstCost[6].EditedCIFPrice != null) ? (lstCost[6].EditedCIFPrice.ToString()) : (((100 * lstCost[6].IndimanCost) / (100 - lstCost[6].Markup)).ToString()))
        //                : ((!rbCalculatedPrice.Checked && lstCost[6].EditedFOBPrice != null) ? (EditedFOBPrice6.ToString()) : (((100 * (lstCost[6].IndimanCost - o.ConvertionFactor)) / (100 - lstCost[6].Markup)).ToString())), "M" + row, "M" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

        //            excell_app.AddData(row, 14, (priceTerm == 1) ? ((!rbCalculatedPrice.Checked && lstCost[7].EditedCIFPrice != null) ? (lstCost[7].EditedCIFPrice.ToString()) : (((100 * lstCost[7].IndimanCost) / (100 - lstCost[7].Markup)).ToString()))
        //                : ((!rbCalculatedPrice.Checked && lstCost[7].EditedFOBPrice != null) ? (EditedFOBPrice7.ToString()) : (((100 * (lstCost[7].IndimanCost - o.ConvertionFactor)) / (100 - lstCost[7].Markup)).ToString())), "N" + row, "N" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);


        //            row++;
        //            i++;

        //            xlProgress = Math.Round(((double.Parse("100") / double.Parse(lstpr.Count.ToString())) * i), 0);

        //            // Writing progress in text file.
        //            /* string lines = xlProgress.ToString();
        //             System.IO.StreamWriter file = new System.IO.StreamWriter(textFilePath, false);
        //             file.WriteLine(lines);
        //             file.Close();*/
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        // Log the error
        //        IndicoLogging.log.Error("Error occured while Generation Label Excel.", ex);
        //    }
        //    finally
        //    {
        //        // Set AutoFilter colums
        //        excell_app.AutoFilter(row);
        //        // Save & Close the Excel Document
        //        excell_app.CloseDocument(filePath);

        //        // release the lock
        //        IndicoPage.RWLock.ReleaseWriterLock();
        //    }
        //}

        private void GenerateExcel(string filePath, int priceTerm, string priceTermName)
        {
            // get a write lock on scCacheKeys
            IndicoPage.RWLock.AcquireWriterLock(Timeout.Infinite);

            // Excel
            //double xlProgress = 0;
            int i = 0;
            string creativeDesign = string.Empty;
            string studioDesign = string.Empty;
            string thirdPartyDesign = string.Empty;
            string position1 = string.Empty;
            string position2 = string.Empty;
            string position3 = string.Empty;
            string priceValidDate = string.Empty;
            int row = 7;

            DefaultValuesPriceListBO objDefaultPriceList = new DefaultValuesPriceListBO().SearchObjects().SingleOrDefault();
            //string lines = xlProgress.ToString();           

            CreateOpenXMLExcel openxml_Excel = new CreateOpenXMLExcel("Indico Excel");

            #region checkDesign

            if (checkCreativeDesign.Checked)
            {
                if (!string.IsNullOrEmpty(txtCreativeDesign.Text) && this.txtCreativeDesign.Text != objDefaultPriceList.CreativeDesign.ToString())
                {
                    creativeDesign = "Creative Design Set Up Fee: $" + txtCreativeDesign.Text + " + GST per Job";
                }
                else
                {
                    creativeDesign = "Creative Design Set Up Fee: $" + objDefaultPriceList.CreativeDesign.ToString() + " + GST per Job";
                }
            }
            if (checkStudioDesign.Checked)
            {
                if (!string.IsNullOrEmpty(txtStudioDesign.Text) && this.txtStudioDesign.Text != objDefaultPriceList.StudioDesign.ToString())
                {
                    studioDesign = "Studio Design Set Up Fee: $" + txtStudioDesign.Text + " + GST per Job";
                }
                else
                {
                    studioDesign = "Studio Design Set Up Fee: $" + objDefaultPriceList.StudioDesign.ToString() + " + GST per Job";
                }
            }
            if (checkThirdPartyDesign.Checked)
            {
                if (!string.IsNullOrEmpty(txtThirdPartyDesign.Text) && this.txtThirdPartyDesign.Text != objDefaultPriceList.ThirdPartyDesign.ToString())
                {
                    thirdPartyDesign = "Third Party Design Set Up Fee: $" + txtThirdPartyDesign.Text + " + GST per Job";
                }
                else
                {
                    thirdPartyDesign = "Third Party Design Set Up Fee: $" + objDefaultPriceList.ThirdPartyDesign.ToString() + " + GST per Job";
                }
            }

            #endregion

            #region checkPsotion

            if (checkPositionOne.Checked)
            {
                if (!string.IsNullOrEmpty(txtPositionOne.Text) && this.txtPositionOne.Text != objDefaultPriceList.Position1.ToString())
                {
                    position1 = "1 x Position @ $" + txtPositionOne.Text + " - eg name on left chest";
                }
                else
                {
                    position1 = "1 x Position @ $" + objDefaultPriceList.Position1.ToString() + " - eg name on left chest";
                }
            }
            if (checkPositionTwo.Checked)
            {
                if (!string.IsNullOrEmpty(txtPositionTwo.Text) && this.txtPositionTwo.Text != objDefaultPriceList.Position2.ToString())
                {
                    position2 = "2 x Positions @ $" + txtPositionTwo.Text + " - eg names on left chest and upper back";
                }
                else
                {
                    position2 = "2 x Positions @ $" + objDefaultPriceList.Position2.ToString() + " - eg names on left chest and upper back";
                }
            }
            if (checkPositionThree.Checked)
            {
                if (!string.IsNullOrEmpty(txtPositionThree.Text) && this.txtPositionThree.Text != objDefaultPriceList.Position3.ToString())
                {
                    position3 = "3 x Positions @ $" + txtPositionThree.Text + " - eg names on left chest, upper back and number on lower back";
                }
                else
                {
                    position3 = "3 x Positions @ $" + objDefaultPriceList.Position3.ToString() + " - eg names on left chest, upper back and number on lower back";
                }
            }
            #endregion

            try
            {
                int distributor = int.Parse(this.ddlDistributorsExcel.SelectedValue);

                String excelType = string.Empty;

                #region Change Column Width

                openxml_Excel.ChangeColumnWidth(1, 13);//A
                openxml_Excel.ChangeColumnWidth(2, 30);//B
                openxml_Excel.ChangeColumnWidth(3, 10);//C
                openxml_Excel.ChangeColumnWidth(4, 36);//D
                openxml_Excel.ChangeColumnWidth(5, 50);//E
                openxml_Excel.ChangeColumnWidth(6, 40);//F
                openxml_Excel.ChangeColumnWidth(7, 10);//G
                openxml_Excel.ChangeColumnWidth(8, 10);//H
                openxml_Excel.ChangeColumnWidth(9, 10);//I
                openxml_Excel.ChangeColumnWidth(10, 10);//J
                openxml_Excel.ChangeColumnWidth(11, 10);//K
                openxml_Excel.ChangeColumnWidth(12, 10);//L
                openxml_Excel.ChangeColumnWidth(13, 10);//M
                openxml_Excel.ChangeColumnWidth(14, 10);//N


                #endregion

                #region HeaderData

                // first row
                openxml_Excel.AddHeaderData("A1", "" + this.ddlDistributorsExcel.SelectedItem.Text.ToUpper() + " - " + priceTerm + "PRICE LIST ALL PLUS GST PLUS LOCAL FREIGHT EX-ADELAIDE", "Calibri", true, XLAlignmentHorizontalValues.Left, 11, "A1:D1", XLCellValues.Text);

                // Second row
                openxml_Excel.AddHeaderData("A2", "INDICO PTY LTD", "Calibri", true, XLAlignmentHorizontalValues.Left, 11, "A2:B2", XLCellValues.Text);
                openxml_Excel.AddHeaderData("C2", "Published Date: " + DateTime.Now.ToString("dd MMMM yyyy"), "Calibri", true, XLAlignmentHorizontalValues.Left, 11, "C2:D2", XLCellValues.Text);
                openxml_Excel.AddHeaderData("E2", "" + creativeDesign + "     " + studioDesign + "     " + thirdPartyDesign + "", "Calibri", true, XLAlignmentHorizontalValues.Left, 11, "E2:F2", XLCellValues.Text);
                openxml_Excel.AddHeaderData("G2", "QUANTITY", "Calibri", true, XLAlignmentHorizontalValues.Center, 11, "G2:N2", XLCellValues.Text);

                // Fourth row
                openxml_Excel.AddHeaderData("A4", "Individual Names & Numbers are charged as follows:     " + position1 + "     " + position2 + "    " + position3 + " ", "Calibri", true, XLAlignmentHorizontalValues.Left, 11, "A4:F4", XLCellValues.Text);
                openxml_Excel.AddHeaderData("G4", "All re-orders under 20 units wll have the benefit of receiving the 20 unit price", "Calibri", true, XLAlignmentHorizontalValues.Center, 11, "G4:N4", XLCellValues.Text);

                //Header
                openxml_Excel.AddHeaderData("A6", "SPORTS CATEGORY", "Calibri", false, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text);
                openxml_Excel.AddHeaderData("B6", "OTHER CATEGORIES", "Calibri", false, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text);
                openxml_Excel.AddHeaderData("C6", "PATTERN", "Calibri", false, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text);
                openxml_Excel.AddHeaderData("D6", "ITEM SUB CATEGORY", "Calibri", false, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text);
                openxml_Excel.AddHeaderData("E6", "DESCRIPTION", "Calibri", false, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text);
                openxml_Excel.AddHeaderData("F6", "FABRIC", "Calibri", false, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text);
                openxml_Excel.AddHeaderData("G6", "'1-5", "Calibri", false, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text, XLColor.Orange);
                openxml_Excel.AddHeaderData("H6", "'6 - 9", "Calibri", false, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text, XLColor.Orange);
                openxml_Excel.AddHeaderData("I6", "'10 - 19", "Calibri", false, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text, XLColor.Orange);
                openxml_Excel.AddHeaderData("J6", "'20 - 49", "Calibri", false, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text);
                openxml_Excel.AddHeaderData("K6", "'50 - 99", "Calibri", false, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text);
                openxml_Excel.AddHeaderData("L6", "'100 - 249", "Calibri", false, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text);
                openxml_Excel.AddHeaderData("M6", "'250 - 499", "Calibri", false, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text);
                openxml_Excel.AddHeaderData("N6", "'500+", "Calibri", false, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text);

                #endregion

                //------------------------------------------------------------------------------------------------------------------------\\

                string categoryName = string.Empty;
                // int row = 7;


                List<ReturnIndimanPriceListDataViewBO> lstIndimanPriceListData = new List<ReturnIndimanPriceListDataViewBO>();
                lstIndimanPriceListData = PriceLevelCostBO.GeIndimanPriceListData(distributor);

                List<IGrouping<int, ReturnIndimanPriceListDataViewBO>> lstPrice = lstIndimanPriceListData.GroupBy(o => (int)o.Price).ToList();

                foreach (IGrouping<int, ReturnIndimanPriceListDataViewBO> Price in lstPrice)
                {
                    List<ReturnIndimanPriceListDataViewBO> lstPriceDetails = Price.ToList();

                    if (categoryName == string.Empty || categoryName != lstPriceDetails[0].SportsCategory)
                    {
                        openxml_Excel.AddCellValue("A" + row.ToString(), string.Empty, "Calibri", false, XLAlignmentHorizontalValues.Left, 11, XLCellValues.Text);
                        categoryName = lstPriceDetails[0].SportsCategory;

                        row++;
                    }

                    openxml_Excel.AddCellValue("A" + row.ToString(), lstPriceDetails[0].SportsCategory, "Calibri", false, XLAlignmentHorizontalValues.Left, 11, XLCellValues.Text);
                    openxml_Excel.AddCellValue("B" + row.ToString(), lstPriceDetails[0].OtherCategories, "Calibri", false, XLAlignmentHorizontalValues.Left, 11, XLCellValues.Text);
                    openxml_Excel.AddCellValue("C" + row.ToString(), lstPriceDetails[0].Number, "Calibri", false, XLAlignmentHorizontalValues.Left, 11, XLCellValues.Text);
                    openxml_Excel.AddCellValue("D" + row.ToString(), lstPriceDetails[0].ItemSubCategoris, "Calibri", false, XLAlignmentHorizontalValues.Left, 11, XLCellValues.Text);
                    openxml_Excel.AddCellValue("E" + row.ToString(), lstPriceDetails[0].NickName, "Calibri", false, XLAlignmentHorizontalValues.Left, 11, XLCellValues.Text);
                    openxml_Excel.AddCellValue("F" + row.ToString(), lstPriceDetails[0].FabricCodenNickName, "Calibri", false, XLAlignmentHorizontalValues.Left, 11, XLCellValues.Text);

                    //0
                    openxml_Excel.AddCellValueNumberFormat("G" + row.ToString(), Math.Round((priceTerm == 1) ? (decimal)lstPriceDetails[0].EditedCIFPrice : (decimal)lstPriceDetails[0].EditedFOBPrice, 2).ToString(), "Calibri", false, XLAlignmentHorizontalValues.Left, 11, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", XLColor.Orange);

                    //1
                    openxml_Excel.AddCellValueNumberFormat("H" + row.ToString(), Math.Round((priceTerm == 1) ? (decimal)lstPriceDetails[1].EditedCIFPrice : (decimal)lstPriceDetails[1].EditedFOBPrice, 2).ToString(), "Calibri", false, XLAlignmentHorizontalValues.Left, 11, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", XLColor.Orange);

                    //2
                    openxml_Excel.AddCellValueNumberFormat("I" + row.ToString(), Math.Round((priceTerm == 1) ? (decimal)lstPriceDetails[2].EditedCIFPrice : (decimal)lstPriceDetails[2].EditedFOBPrice, 2).ToString(), "Calibri", false, XLAlignmentHorizontalValues.Left, 11, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", XLColor.Orange);

                    //3
                    openxml_Excel.AddCellValueNumberFormat("J" + row.ToString(), Math.Round((priceTerm == 1) ? (decimal)lstPriceDetails[3].EditedCIFPrice : (decimal)lstPriceDetails[3].EditedFOBPrice, 2).ToString(), "Calibri", false, XLAlignmentHorizontalValues.Left, 11, "\"$\"#,##0.00;[Red]\"$\"#,##0.00");

                    //4
                    openxml_Excel.AddCellValueNumberFormat("K" + row.ToString(), Math.Round((priceTerm == 1) ? (decimal)lstPriceDetails[4].EditedCIFPrice : (decimal)lstPriceDetails[4].EditedFOBPrice, 2).ToString(), "Calibri", false, XLAlignmentHorizontalValues.Left, 11, "\"$\"#,##0.00;[Red]\"$\"#,##0.00");

                    //5
                    openxml_Excel.AddCellValueNumberFormat("L" + row.ToString(), Math.Round((priceTerm == 1) ? (decimal)lstPriceDetails[5].EditedCIFPrice : (decimal)lstPriceDetails[5].EditedFOBPrice, 2).ToString(), "Calibri", false, XLAlignmentHorizontalValues.Left, 11, "\"$\"#,##0.00;[Red]\"$\"#,##0.00");

                    //5
                    openxml_Excel.AddCellValueNumberFormat("L" + row.ToString(), Math.Round((priceTerm == 1) ? (decimal)lstPriceDetails[5].EditedCIFPrice : (decimal)lstPriceDetails[5].EditedFOBPrice, 2).ToString(), "Calibri", false, XLAlignmentHorizontalValues.Left, 11, "\"$\"#,##0.00;[Red]\"$\"#,##0.00");

                    //6
                    openxml_Excel.AddCellValueNumberFormat("M" + row.ToString(), Math.Round((priceTerm == 1) ? (decimal)lstPriceDetails[6].EditedCIFPrice : (decimal)lstPriceDetails[6].EditedFOBPrice, 2).ToString(), "Calibri", false, XLAlignmentHorizontalValues.Left, 11, "\"$\"#,##0.00;[Red]\"$\"#,##0.00");

                    //7
                    openxml_Excel.AddCellValueNumberFormat("N" + row.ToString(), Math.Round((priceTerm == 1) ? (decimal)lstPriceDetails[7].EditedCIFPrice : (decimal)lstPriceDetails[7].EditedFOBPrice, 2).ToString(), "Calibri", false, XLAlignmentHorizontalValues.Left, 11, "\"$\"#,##0.00;[Red]\"$\"#,##0.00");

                    row++;
                }


            }
            catch (Exception ex)
            {
                // Log the error
                IndicoLogging.log.Error("Error occured while Generation Excel.", ex);
            }
            finally
            {
                // Set AutoFilter colums
                openxml_Excel.AutotFilter("A6:F" + row.ToString());

                // FreeZe Pane
                openxml_Excel.FreezePane(6, 6);

                // Save & Close the Excel Document               
                openxml_Excel.CloseDocument(filePath);


                // release the lock
                IndicoPage.RWLock.ReleaseWriterLock();
            }
        }

        //private void GenerateLabelExcel(string filePath, int priceTerm, string priceTermName)
        //{
        //    // get a write lock on scCacheKeys
        //    IndicoPage.RWLock.AcquireWriterLock(Timeout.Infinite);

        //    // Excel
        //    double xlProgress = 0;
        //    int i = 0;
        //    string creativeDesign = string.Empty;
        //    string studioDesign = string.Empty;
        //    string thirdPartyDesign = string.Empty;
        //    string position1 = string.Empty;
        //    string position2 = string.Empty;
        //    string position3 = string.Empty;
        //    string priceValidDate = string.Empty;
        //    int row = 7;
        //    DefaultValuesPriceListBO objDefaultPriceList = new DefaultValuesPriceListBO().SearchObjects().SingleOrDefault();
        //    /* string textFilePath = IndicoConfiguration.AppConfiguration.PathToDataFolder + @"\Temp\progress_" + 1 + ".txt";
        //     if (File.Exists(textFilePath))
        //     {
        //         File.Delete(textFilePath);
        //     }*/

        //    CreateExcelDocument excell_app = new CreateExcelDocument(true);

        //    #region checkDesign

        //    if (checkCreativeDesign.Checked)
        //    {
        //        if (!string.IsNullOrEmpty(txtCreativeDesign.Text) && this.txtCreativeDesign.Text != objDefaultPriceList.CreativeDesign.ToString())
        //        {
        //            creativeDesign = "Creative Design Set Up Fee: $" + txtCreativeDesign.Text + " + GST per Job";
        //        }
        //        else
        //        {
        //            creativeDesign = "Creative Design Set Up Fee: $" + objDefaultPriceList.CreativeDesign.ToString() + " + GST per Job";
        //        }
        //    }
        //    if (checkStudioDesign.Checked)
        //    {
        //        if (!string.IsNullOrEmpty(txtStudioDesign.Text) && this.txtStudioDesign.Text != objDefaultPriceList.StudioDesign.ToString())
        //        {
        //            studioDesign = "Studio Design Set Up Fee: $" + txtStudioDesign.Text + " + GST per Job";
        //        }
        //        else
        //        {
        //            studioDesign = "Studio Design Set Up Fee: $" + objDefaultPriceList.StudioDesign.ToString() + " + GST per Job";
        //        }
        //    }
        //    if (checkThirdPartyDesign.Checked)
        //    {
        //        if (!string.IsNullOrEmpty(txtThirdPartyDesign.Text) && this.txtThirdPartyDesign.Text != objDefaultPriceList.ThirdPartyDesign.ToString())
        //        {
        //            thirdPartyDesign = "Third Party Design Set Up Fee: $" + txtThirdPartyDesign.Text + " + GST per Job";
        //        }
        //        else
        //        {
        //            thirdPartyDesign = "Third Party Design Set Up Fee: $" + objDefaultPriceList.ThirdPartyDesign.ToString() + " + GST per Job";
        //        }
        //    }

        //    #endregion

        //    #region checkPsotion

        //    if (checkPositionOne.Checked)
        //    {
        //        if (!string.IsNullOrEmpty(txtPositionOne.Text) && this.txtPositionOne.Text != objDefaultPriceList.Position1.ToString())
        //        {
        //            position1 = "1 x Position @ $" + txtPositionOne.Text + " - eg name on left chest";
        //        }
        //        else
        //        {
        //            position1 = "1 x Position @ $" + objDefaultPriceList.Position1.ToString() + " - eg name on left chest";
        //        }
        //    }
        //    if (checkPositionTwo.Checked)
        //    {
        //        if (!string.IsNullOrEmpty(txtPositionTwo.Text) && this.txtPositionTwo.Text != objDefaultPriceList.Position2.ToString())
        //        {
        //            position2 = "2 x Positions @ $" + txtPositionTwo.Text + " - eg names on left chest and upper back";
        //        }
        //        else
        //        {
        //            position2 = "2 x Positions @ $" + objDefaultPriceList.Position2.ToString() + " - eg names on left chest and upper back";
        //        }
        //    }
        //    if (checkPositionThree.Checked)
        //    {
        //        if (!string.IsNullOrEmpty(txtPositionThree.Text) && this.txtPositionThree.Text != objDefaultPriceList.Position3.ToString())
        //        {
        //            position3 = "3 x Positions @ $" + txtPositionThree.Text + " - eg names on left chest, upper back and number on lower back";
        //        }
        //        else
        //        {
        //            position3 = "3 x Positions @ $" + objDefaultPriceList.Position3.ToString() + " - eg names on left chest, upper back and number on lower back";
        //        }
        //    }
        //    #endregion



        //    try
        //    {
        //        int label = int.Parse(this.ddlLabelExcel.SelectedValue);

        //        String excelType = string.Empty;
        //        PriceBO objPrice = new PriceBO();
        //        ExcelPriceLevelCostViewBO excel = new ExcelPriceLevelCostViewBO();
        //        List<ExcelPriceLevelCostViewBO> lstpr = (from o in excel.SearchObjects()
        //                                                 orderby o.SportsCategory
        //                                                 select o).ToList();

        //        // first row
        //        excell_app.AddHeaderData(1, 1, "" + this.ddlLabelExcel.SelectedItem.Text.ToUpper() + " - " + priceTermName + " PRICE LIST ALL PLUS GST PLUS LOCAL FREIGHT EX-ADELAIDE", "A1", "D1", true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignLeft, "General");
        //        // Second row
        //        excell_app.AddHeaderData(2, 1, "INDICO PTY LTD", "A2", "B2", true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignLeft, "General");
        //        excell_app.AddHeaderData(2, 3, "Published Date: " + DateTime.Now.ToString("dd MMMM yyyy") + "", "C2", "D2", true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignLeft, "General");
        //        excell_app.AddHeaderData(2, 5, "" + creativeDesign + "     " + studioDesign + "     " + thirdPartyDesign + "", "E2", "F2", true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignLeft, "General");
        //        excell_app.AddHeaderData(2, 9, "QUANTITY", "G2", "N2", true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        // Third row
        //        // excell_app.AddHeaderData(3, 3, priceValidDate, "C5", "D5", true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignLeft, "dd MMMM yyyy");
        //        // Fourth row
        //        excell_app.AddHeaderData(4, 1, "Individual Names & Numbers are charged as follows:     " + position1 + "     " + position2 + "    " + position3 + " ", "A4", "F4", true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignLeft, "General");
        //        excell_app.AddHeaderData(4, 9, "All re-orders under 20 units wll have the benefit of receiving the 20 unit price", "G4", "N4", true, true, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        // Column headers
        //        excell_app.AddHeaderData(6, 1, "SPORTS CATEGORY", "A6", "A6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(6, 2, "OTHER CATEGORIES", "B6", "B6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(6, 3, "PATTERN", "C6", "C6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(6, 4, "ITEM SUB CATEGORY", "D6", "D6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(6, 5, "DESCRIPTION", "E6", "E6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(6, 6, "FABRIC", "F6", "F6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderDataWithBackgroundColor(6, 7, "'1-5", "G6", "G6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter);
        //        excell_app.AddHeaderDataWithBackgroundColor(6, 8, "'6 - 9", "H6", "H6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter);
        //        excell_app.AddHeaderDataWithBackgroundColor(6, 9, "'10 - 19", "I6", "I6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter);
        //        excell_app.AddHeaderData(6, 10, "20 - 49", "J6", "J6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(6, 11, "50 - 99", "K6", "K6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(6, 12, "100 - 249", "L6", "L6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(6, 13, "250 - 499", "M6", "M6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        excell_app.AddHeaderData(6, 14, "500+", "N6", "N6", false, false, "Calibri", 11, Excel.XlHAlign.xlHAlignCenter, "General");
        //        //------------------------------------------------------------------------------------------------------------------------\\

        //        string categoryName = string.Empty;
        //        // int row = 7;

        //        LabelPatternPriceLevelCostViewBO cost = new LabelPatternPriceLevelCostViewBO();
        //        List<LabelPatternPriceLevelCostViewBO> lstCost = null;


        //        List<int> indicoPrice = new List<int>();
        //        foreach (ExcelPriceLevelCostViewBO o in lstpr)
        //        {

        //            cost.Price = o.PriceID;
        //            cost.Label = label;
        //            lstCost = cost.SearchObjects();


        //            if (categoryName == string.Empty || categoryName != o.SportsCategory)
        //            {
        //                excell_app.AddData(row, 1, "", "A" + row, "A" + row, null, Excel.XlHAlign.xlHAlignLeft);
        //                categoryName = o.SportsCategory;

        //                row++;
        //            }
        //            excell_app.AddData(row, 1, o.SportsCategory, "A" + row, "A" + row, null, Excel.XlHAlign.xlHAlignLeft);
        //            excell_app.AddData(row, 2, o.OtherCategories, "B" + row, "B" + row, null, Excel.XlHAlign.xlHAlignLeft);
        //            excell_app.AddData(row, 3, "'" + o.Number, "C" + row, "C" + row, "@", Excel.XlHAlign.xlHAlignLeft);
        //            excell_app.AddData(row, 4, (o.ItemSubCategoris != null) ? o.ItemSubCategoris.ToUpper() : string.Empty, "D" + row, "D" + row, null, Excel.XlHAlign.xlHAlignLeft);
        //            excell_app.AddData(row, 5, o.NickName.ToUpper(), "E" + row, "E" + row, null, Excel.XlHAlign.xlHAlignLeft);
        //            excell_app.AddData(row, 6, o.FabricCodenNickName.ToUpper(), "F" + row, "F" + row, null, Excel.XlHAlign.xlHAlignLeft);

        //            if (i == 433)
        //            {

        //            }

        //            decimal indicoCIFMarkup0 = (lstCost[0].EditedCIFPrice != null && lstCost[0].EditedCIFPrice != 0) ? Math.Round(100 - ((lstCost[0].IndimanCost.Value * 100) / lstCost[0].EditedCIFPrice.Value), 2) : lstCost[0].Markup.Value;
        //            decimal EditedFOBPrice0 = (lstCost[0].EditedFOBPrice != null && lstCost[0].EditedFOBPrice.Value != 0) ? lstCost[0].EditedFOBPrice.Value : (lstCost[0].IndimanCost != 0) ? Math.Round(((lstCost[0].IndimanCost.Value - o.ConvertionFactor.Value)) / (1 - (indicoCIFMarkup0 / 100)), 2) : 0;

        //            decimal indicoCIFMarkup1 = (lstCost[1].EditedCIFPrice != null && lstCost[1].EditedCIFPrice != 0) ? Math.Round(100 - ((lstCost[1].IndimanCost.Value * 100) / lstCost[1].EditedCIFPrice.Value), 2) : lstCost[1].Markup.Value;
        //            decimal EditedFOBPrice1 = (lstCost[1].EditedFOBPrice != null && lstCost[1].EditedFOBPrice.Value != 0) ? lstCost[1].EditedFOBPrice.Value : (lstCost[1].IndimanCost != 0) ? Math.Round(((lstCost[1].IndimanCost.Value - o.ConvertionFactor.Value)) / (1 - (indicoCIFMarkup1 / 100)), 2) : 0;

        //            decimal indicoCIFMarkup2 = (lstCost[2].EditedCIFPrice != null && lstCost[2].EditedCIFPrice != 0) ? Math.Round(100 - ((lstCost[2].IndimanCost.Value * 100) / lstCost[2].EditedCIFPrice.Value), 2) : lstCost[2].Markup.Value;
        //            decimal EditedFOBPrice2 = (lstCost[2].EditedFOBPrice != null && lstCost[2].EditedFOBPrice.Value != 0) ? lstCost[2].EditedFOBPrice.Value : (lstCost[2].IndimanCost != 0) ? Math.Round(((lstCost[2].IndimanCost.Value - o.ConvertionFactor.Value)) / (1 - (indicoCIFMarkup2 / 100)), 2) : 0;

        //            decimal indicoCIFMarkup3 = (lstCost[3].EditedCIFPrice != null && lstCost[3].EditedCIFPrice != 0) ? Math.Round(100 - ((lstCost[3].IndimanCost.Value * 100) / lstCost[3].EditedCIFPrice.Value), 2) : lstCost[3].Markup.Value;
        //            decimal EditedFOBPrice3 = (lstCost[3].EditedFOBPrice != null && lstCost[3].EditedFOBPrice.Value != 0) ? lstCost[3].EditedFOBPrice.Value : (lstCost[3].IndimanCost != 0) ? Math.Round(((lstCost[3].IndimanCost.Value - o.ConvertionFactor.Value)) / (1 - (indicoCIFMarkup3 / 100)), 2) : 0;

        //            decimal indicoCIFMarkup4 = (lstCost[4].EditedCIFPrice != null && lstCost[4].EditedCIFPrice != 0) ? Math.Round(100 - ((lstCost[4].IndimanCost.Value * 100) / lstCost[4].EditedCIFPrice.Value), 2) : lstCost[4].Markup.Value;
        //            decimal EditedFOBPrice4 = (lstCost[4].EditedFOBPrice != null && lstCost[4].EditedFOBPrice.Value != 0) ? lstCost[4].EditedFOBPrice.Value : (lstCost[4].IndimanCost != 0) ? Math.Round(((lstCost[4].IndimanCost.Value - o.ConvertionFactor.Value)) / (1 - (indicoCIFMarkup4 / 100)), 2) : 0;

        //            decimal indicoCIFMarkup5 = (lstCost[5].EditedCIFPrice != null && lstCost[5].EditedCIFPrice != 0) ? Math.Round(100 - ((lstCost[5].IndimanCost.Value * 100) / lstCost[5].EditedCIFPrice.Value), 2) : lstCost[5].Markup.Value;
        //            decimal EditedFOBPrice5 = (lstCost[5].EditedFOBPrice != null && lstCost[5].EditedFOBPrice.Value != 0) ? lstCost[5].EditedFOBPrice.Value : (lstCost[5].IndimanCost != 0) ? Math.Round(((lstCost[5].IndimanCost.Value - o.ConvertionFactor.Value)) / (1 - (indicoCIFMarkup5 / 100)), 2) : 0;

        //            decimal indicoCIFMarkup6 = (lstCost[6].EditedCIFPrice != null && lstCost[6].EditedCIFPrice != 0) ? Math.Round(100 - ((lstCost[6].IndimanCost.Value * 100) / lstCost[6].EditedCIFPrice.Value), 2) : lstCost[6].Markup.Value;
        //            decimal EditedFOBPrice6 = (lstCost[6].EditedFOBPrice != null && lstCost[6].EditedFOBPrice.Value != 0) ? lstCost[6].EditedFOBPrice.Value : (lstCost[6].IndimanCost != 0) ? Math.Round(((lstCost[6].IndimanCost.Value - o.ConvertionFactor.Value)) / (1 - (indicoCIFMarkup6 / 100)), 2) : 0;

        //            decimal indicoCIFMarkup7 = (lstCost[7].EditedCIFPrice != null && lstCost[7].EditedCIFPrice != 0) ? Math.Round(100 - ((lstCost[7].IndimanCost.Value * 100) / lstCost[7].EditedCIFPrice.Value), 2) : lstCost[7].Markup.Value;
        //            decimal EditedFOBPrice7 = (lstCost[7].EditedFOBPrice != null && lstCost[7].EditedFOBPrice.Value != 0) ? lstCost[7].EditedFOBPrice.Value : (lstCost[7].IndimanCost != 0) ? Math.Round(((lstCost[7].IndimanCost.Value - o.ConvertionFactor.Value)) / (1 - (indicoCIFMarkup7 / 100)), 2) : 0;


        //            decimal calCIFPrice = (decimal)((100 * lstCost[0].IndimanCost) / (100 - lstCost[0].Markup));
        //            decimal calFOBPrice = (decimal)((100 * (lstCost[0].IndimanCost - o.ConvertionFactor)) / (100 - lstCost[0].Markup));

        //            excell_app.AddDataWithBackgroundColor(row, 7, (priceTerm == 1) ? ((!rbCalculatedPrice.Checked && lstCost[0].EditedCIFPrice != null) ? (lstCost[0].EditedCIFPrice.ToString()) : (((100 * lstCost[0].IndimanCost) / (100 - lstCost[0].Markup)).ToString()))
        //                : ((!rbCalculatedPrice.Checked && lstCost[0].EditedFOBPrice != null) ? (EditedFOBPrice0.ToString()) : (((100 * (lstCost[0].IndimanCost - o.ConvertionFactor)) / (100 - lstCost[0].Markup)).ToString())), "G" + row, "G" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

        //            excell_app.AddDataWithBackgroundColor(row, 8, (priceTerm == 1) ? ((!rbCalculatedPrice.Checked && lstCost[1].EditedCIFPrice != null) ? (lstCost[1].EditedCIFPrice.ToString()) : (((100 * lstCost[1].IndimanCost) / (100 - lstCost[1].Markup)).ToString()))
        //                : ((!rbCalculatedPrice.Checked && lstCost[1].EditedFOBPrice != null) ? (EditedFOBPrice1.ToString()) : (((100 * (lstCost[1].IndimanCost - o.ConvertionFactor)) / (100 - lstCost[1].Markup)).ToString())), "H" + row, "H" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

        //            excell_app.AddDataWithBackgroundColor(row, 9, (priceTerm == 1) ? ((!rbCalculatedPrice.Checked && lstCost[2].EditedCIFPrice != null) ? (lstCost[2].EditedCIFPrice.ToString()) : (((100 * lstCost[2].IndimanCost) / (100 - lstCost[2].Markup)).ToString()))
        //                : ((!rbCalculatedPrice.Checked && lstCost[2].EditedFOBPrice != null) ? (EditedFOBPrice2.ToString()) : (((100 * (lstCost[2].IndimanCost - o.ConvertionFactor)) / (100 - lstCost[2].Markup)).ToString())), "I" + row, "I" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

        //            excell_app.AddData(row, 10, (priceTerm == 1) ? ((!rbCalculatedPrice.Checked && lstCost[3].EditedCIFPrice != null) ? (lstCost[3].EditedCIFPrice.ToString()) : (((100 * lstCost[3].IndimanCost) / (100 - lstCost[3].Markup)).ToString()))
        //                : ((!rbCalculatedPrice.Checked && lstCost[3].EditedFOBPrice != null) ? (EditedFOBPrice3.ToString()) : (((100 * (lstCost[3].IndimanCost - o.ConvertionFactor)) / (100 - lstCost[3].Markup)).ToString())), "J" + row, "J" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

        //            excell_app.AddData(row, 11, (priceTerm == 1) ? ((!rbCalculatedPrice.Checked && lstCost[4].EditedCIFPrice != null) ? (lstCost[4].EditedCIFPrice.ToString()) : (((100 * lstCost[4].IndimanCost) / (100 - lstCost[4].Markup)).ToString()))
        //                : ((!rbCalculatedPrice.Checked && lstCost[4].EditedFOBPrice != null) ? (EditedFOBPrice4.ToString()) : (((100 * (lstCost[4].IndimanCost - o.ConvertionFactor)) / (100 - lstCost[4].Markup)).ToString())), "K" + row, "K" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

        //            excell_app.AddData(row, 12, (priceTerm == 1) ? ((!rbCalculatedPrice.Checked && lstCost[5].EditedCIFPrice != null) ? (lstCost[5].EditedCIFPrice.ToString()) : (((100 * lstCost[5].IndimanCost) / (100 - lstCost[5].Markup)).ToString()))
        //                : ((!rbCalculatedPrice.Checked && lstCost[5].EditedFOBPrice != null) ? (EditedFOBPrice5.ToString()) : (((100 * (lstCost[5].IndimanCost - o.ConvertionFactor)) / (100 - lstCost[5].Markup)).ToString())), "L" + row, "L" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

        //            excell_app.AddData(row, 13, (priceTerm == 1) ? ((!rbCalculatedPrice.Checked && lstCost[6].EditedCIFPrice != null) ? (lstCost[6].EditedCIFPrice.ToString()) : (((100 * lstCost[6].IndimanCost) / (100 - lstCost[6].Markup)).ToString()))
        //                : ((!rbCalculatedPrice.Checked && lstCost[6].EditedFOBPrice != null) ? (EditedFOBPrice6.ToString()) : (((100 * (lstCost[6].IndimanCost - o.ConvertionFactor)) / (100 - lstCost[6].Markup)).ToString())), "M" + row, "M" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);

        //            excell_app.AddData(row, 14, (priceTerm == 1) ? ((!rbCalculatedPrice.Checked && lstCost[7].EditedCIFPrice != null) ? (lstCost[7].EditedCIFPrice.ToString()) : (((100 * lstCost[7].IndimanCost) / (100 - lstCost[7].Markup)).ToString()))
        //                : ((!rbCalculatedPrice.Checked && lstCost[7].EditedFOBPrice != null) ? (EditedFOBPrice7.ToString()) : (((100 * (lstCost[7].IndimanCost - o.ConvertionFactor)) / (100 - lstCost[7].Markup)).ToString())), "N" + row, "N" + row, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", Excel.XlHAlign.xlHAlignCenter);


        //            row++;
        //            i++;

        //            xlProgress = Math.Round(((double.Parse("100") / double.Parse(lstpr.Count.ToString())) * i), 0);

        //            // Writing progress in text file.
        //            /* string lines = xlProgress.ToString();
        //             System.IO.StreamWriter file = new System.IO.StreamWriter(textFilePath, false);
        //             file.WriteLine(lines);
        //             file.Close();*/
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        // Log the error
        //        IndicoLogging.log.Error("Error occured while Generation Label Excel.", ex);
        //    }
        //    finally
        //    {
        //        // Set AutoFilter colums
        //        excell_app.AutoFilter(row);
        //        // Save & Close the Excel Document
        //        excell_app.CloseDocument(filePath);

        //        // release the lock
        //        IndicoPage.RWLock.ReleaseWriterLock();
        //    }
        //}

        private void GenerateLabelExcel(string filePath, int priceTerm, string priceTermName)
        {
            // get a write lock on scCacheKeys
            IndicoPage.RWLock.AcquireWriterLock(Timeout.Infinite);

            // Excel
            double xlProgress = 0;
            int i = 0;
            string creativeDesign = string.Empty;
            string studioDesign = string.Empty;
            string thirdPartyDesign = string.Empty;
            string position1 = string.Empty;
            string position2 = string.Empty;
            string position3 = string.Empty;
            string priceValidDate = string.Empty;
            int row = 7;
            DefaultValuesPriceListBO objDefaultPriceList = new DefaultValuesPriceListBO().SearchObjects().SingleOrDefault();
            /* string textFilePath = IndicoConfiguration.AppConfiguration.PathToDataFolder + @"\Temp\progress_" + 1 + ".txt";
             if (File.Exists(textFilePath))
             {
                 File.Delete(textFilePath);
             }*/

            CreateOpenXMLExcel openxml_Excel = new CreateOpenXMLExcel("Label Excel");

            #region checkDesign

            if (checkCreativeDesign.Checked)
            {
                if (!string.IsNullOrEmpty(txtCreativeDesign.Text) && this.txtCreativeDesign.Text != objDefaultPriceList.CreativeDesign.ToString())
                {
                    creativeDesign = "Creative Design Set Up Fee: $" + txtCreativeDesign.Text + " + GST per Job";
                }
                else
                {
                    creativeDesign = "Creative Design Set Up Fee: $" + objDefaultPriceList.CreativeDesign.ToString() + " + GST per Job";
                }
            }
            if (checkStudioDesign.Checked)
            {
                if (!string.IsNullOrEmpty(txtStudioDesign.Text) && this.txtStudioDesign.Text != objDefaultPriceList.StudioDesign.ToString())
                {
                    studioDesign = "Studio Design Set Up Fee: $" + txtStudioDesign.Text + " + GST per Job";
                }
                else
                {
                    studioDesign = "Studio Design Set Up Fee: $" + objDefaultPriceList.StudioDesign.ToString() + " + GST per Job";
                }
            }
            if (checkThirdPartyDesign.Checked)
            {
                if (!string.IsNullOrEmpty(txtThirdPartyDesign.Text) && this.txtThirdPartyDesign.Text != objDefaultPriceList.ThirdPartyDesign.ToString())
                {
                    thirdPartyDesign = "Third Party Design Set Up Fee: $" + txtThirdPartyDesign.Text + " + GST per Job";
                }
                else
                {
                    thirdPartyDesign = "Third Party Design Set Up Fee: $" + objDefaultPriceList.ThirdPartyDesign.ToString() + " + GST per Job";
                }
            }

            #endregion

            #region checkPsotion

            if (checkPositionOne.Checked)
            {
                if (!string.IsNullOrEmpty(txtPositionOne.Text) && this.txtPositionOne.Text != objDefaultPriceList.Position1.ToString())
                {
                    position1 = "1 x Position @ $" + txtPositionOne.Text + " - eg name on left chest";
                }
                else
                {
                    position1 = "1 x Position @ $" + objDefaultPriceList.Position1.ToString() + " - eg name on left chest";
                }
            }
            if (checkPositionTwo.Checked)
            {
                if (!string.IsNullOrEmpty(txtPositionTwo.Text) && this.txtPositionTwo.Text != objDefaultPriceList.Position2.ToString())
                {
                    position2 = "2 x Positions @ $" + txtPositionTwo.Text + " - eg names on left chest and upper back";
                }
                else
                {
                    position2 = "2 x Positions @ $" + objDefaultPriceList.Position2.ToString() + " - eg names on left chest and upper back";
                }
            }
            if (checkPositionThree.Checked)
            {
                if (!string.IsNullOrEmpty(txtPositionThree.Text) && this.txtPositionThree.Text != objDefaultPriceList.Position3.ToString())
                {
                    position3 = "3 x Positions @ $" + txtPositionThree.Text + " - eg names on left chest, upper back and number on lower back";
                }
                else
                {
                    position3 = "3 x Positions @ $" + objDefaultPriceList.Position3.ToString() + " - eg names on left chest, upper back and number on lower back";
                }
            }
            #endregion



            try
            {
                int label = int.Parse(this.ddlLabelExcel.SelectedValue);

                String excelType = string.Empty;
                PriceBO objPrice = new PriceBO();
                ExcelPriceLevelCostViewBO excel = new ExcelPriceLevelCostViewBO();
                List<ExcelPriceLevelCostViewBO> lstpr = (from o in excel.SearchObjects()
                                                         orderby o.SportsCategory
                                                         select o).ToList();

                #region Change Column Width

                openxml_Excel.ChangeColumnWidth(1, 13);//A
                openxml_Excel.ChangeColumnWidth(2, 30);//B
                openxml_Excel.ChangeColumnWidth(3, 10);//C
                openxml_Excel.ChangeColumnWidth(4, 36);//D
                openxml_Excel.ChangeColumnWidth(5, 50);//E
                openxml_Excel.ChangeColumnWidth(6, 40);//F
                openxml_Excel.ChangeColumnWidth(7, 10);//G
                openxml_Excel.ChangeColumnWidth(8, 10);//H
                openxml_Excel.ChangeColumnWidth(9, 10);//I
                openxml_Excel.ChangeColumnWidth(10, 10);//J
                openxml_Excel.ChangeColumnWidth(11, 10);//K
                openxml_Excel.ChangeColumnWidth(12, 10);//L
                openxml_Excel.ChangeColumnWidth(13, 10);//M
                openxml_Excel.ChangeColumnWidth(14, 10);//N


                #endregion

                #region HeaderData

                // first row
                openxml_Excel.AddHeaderData("A1", "" + this.ddlLabelExcel.SelectedItem.Text.ToUpper() + " - " + priceTerm + "PRICE LIST ALL PLUS GST PLUS LOCAL FREIGHT EX-ADELAIDE", "Calibri", true, XLAlignmentHorizontalValues.Left, 11, "A1:D1", XLCellValues.Text);

                // Second row
                openxml_Excel.AddHeaderData("A2", "INDICO PTY LTD", "Calibri", true, XLAlignmentHorizontalValues.Left, 11, "A2:B2", XLCellValues.Text);
                openxml_Excel.AddHeaderData("C2", "Published Date: " + DateTime.Now.ToString("dd MMMM yyyy"), "Calibri", true, XLAlignmentHorizontalValues.Left, 11, "C2:D2", XLCellValues.Text);
                openxml_Excel.AddHeaderData("E2", "" + creativeDesign + "     " + studioDesign + "     " + thirdPartyDesign + "", "Calibri", true, XLAlignmentHorizontalValues.Left, 11, "E2:F2", XLCellValues.Text);
                openxml_Excel.AddHeaderData("G2", "QUANTITY", "Calibri", true, XLAlignmentHorizontalValues.Center, 11, "G2:N2", XLCellValues.Text);

                // Fourth row
                openxml_Excel.AddHeaderData("A4", "Individual Names & Numbers are charged as follows:     " + position1 + "     " + position2 + "    " + position3 + " ", "Calibri", true, XLAlignmentHorizontalValues.Left, 11, "A4:F4", XLCellValues.Text);
                openxml_Excel.AddHeaderData("G4", "All re-orders under 20 units wll have the benefit of receiving the 20 unit price", "Calibri", true, XLAlignmentHorizontalValues.Center, 11, "G4:N4", XLCellValues.Text);

                //Header
                openxml_Excel.AddHeaderData("A6", "SPORTS CATEGORY", "Calibri", false, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text);
                openxml_Excel.AddHeaderData("B6", "OTHER CATEGORIES", "Calibri", false, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text);
                openxml_Excel.AddHeaderData("C6", "PATTERN", "Calibri", false, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text);
                openxml_Excel.AddHeaderData("D6", "ITEM SUB CATEGORY", "Calibri", false, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text);
                openxml_Excel.AddHeaderData("E6", "DESCRIPTION", "Calibri", false, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text);
                openxml_Excel.AddHeaderData("F6", "FABRIC", "Calibri", false, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text);
                openxml_Excel.AddHeaderData("G6", "'1-5", "Calibri", false, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text, XLColor.Orange);
                openxml_Excel.AddHeaderData("H6", "'6 - 9", "Calibri", false, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text, XLColor.Orange);
                openxml_Excel.AddHeaderData("I6", "'10 - 19", "Calibri", false, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text, XLColor.Orange);
                openxml_Excel.AddHeaderData("J6", "'20 - 49", "Calibri", false, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text);
                openxml_Excel.AddHeaderData("K6", "'50 - 99", "Calibri", false, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text);
                openxml_Excel.AddHeaderData("L6", "'100 - 249", "Calibri", false, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text);
                openxml_Excel.AddHeaderData("M6", "'250 - 499", "Calibri", false, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text);
                openxml_Excel.AddHeaderData("N6", "'500+", "Calibri", false, XLAlignmentHorizontalValues.Center, 11, XLCellValues.Text);

                //------------------------------------------------------------------------------------------------------------------------\\

                #endregion




                string categoryName = string.Empty;
                // int row = 7;

                LabelPatternPriceLevelCostViewBO cost = new LabelPatternPriceLevelCostViewBO();
                List<LabelPatternPriceLevelCostViewBO> lstCost = null;


                List<int> indicoPrice = new List<int>();
                foreach (ExcelPriceLevelCostViewBO o in lstpr)
                {

                    cost.Price = o.PriceID;
                    cost.Label = label;
                    lstCost = cost.SearchObjects();


                    if (categoryName == string.Empty || categoryName != o.SportsCategory)
                    {
                        openxml_Excel.AddCellValue("A" + row.ToString(), string.Empty, "Calibri", false, XLAlignmentHorizontalValues.Left, 11, XLCellValues.Text);
                        categoryName = o.SportsCategory;

                        row++;
                    }
                    openxml_Excel.AddCellValue("A" + row.ToString(), o.SportsCategory, "Calibri", false, XLAlignmentHorizontalValues.Left, 11, XLCellValues.Text);
                    openxml_Excel.AddCellValue("B" + row.ToString(), o.OtherCategories, "Calibri", false, XLAlignmentHorizontalValues.Left, 11, XLCellValues.Text);
                    openxml_Excel.AddCellValue("C" + row.ToString(), o.Number, "Calibri", false, XLAlignmentHorizontalValues.Left, 11, XLCellValues.Text);
                    openxml_Excel.AddCellValue("D" + row.ToString(), o.ItemSubCategoris, "Calibri", false, XLAlignmentHorizontalValues.Left, 11, XLCellValues.Text);
                    openxml_Excel.AddCellValue("E" + row.ToString(), o.NickName, "Calibri", false, XLAlignmentHorizontalValues.Left, 11, XLCellValues.Text);
                    openxml_Excel.AddCellValue("F" + row.ToString(), o.FabricCodenNickName, "Calibri", false, XLAlignmentHorizontalValues.Left, 11, XLCellValues.Text);

                    decimal indicoCIFMarkup0 = (lstCost[0].EditedCIFPrice != null && lstCost[0].EditedCIFPrice != 0) ? Math.Round(100 - ((lstCost[0].IndimanCost.Value * 100) / lstCost[0].EditedCIFPrice.Value), 2) : lstCost[0].Markup.Value;
                    decimal EditedFOBPrice0 = (lstCost[0].EditedFOBPrice != null && lstCost[0].EditedFOBPrice.Value != 0) ? lstCost[0].EditedFOBPrice.Value : (lstCost[0].IndimanCost != 0) ? Math.Round(((lstCost[0].IndimanCost.Value - o.ConvertionFactor.Value)) / (1 - (indicoCIFMarkup0 / 100)), 2) : 0;

                    decimal indicoCIFMarkup1 = (lstCost[1].EditedCIFPrice != null && lstCost[1].EditedCIFPrice != 0) ? Math.Round(100 - ((lstCost[1].IndimanCost.Value * 100) / lstCost[1].EditedCIFPrice.Value), 2) : lstCost[1].Markup.Value;
                    decimal EditedFOBPrice1 = (lstCost[1].EditedFOBPrice != null && lstCost[1].EditedFOBPrice.Value != 0) ? lstCost[1].EditedFOBPrice.Value : (lstCost[1].IndimanCost != 0) ? Math.Round(((lstCost[1].IndimanCost.Value - o.ConvertionFactor.Value)) / (1 - (indicoCIFMarkup1 / 100)), 2) : 0;

                    decimal indicoCIFMarkup2 = (lstCost[2].EditedCIFPrice != null && lstCost[2].EditedCIFPrice != 0) ? Math.Round(100 - ((lstCost[2].IndimanCost.Value * 100) / lstCost[2].EditedCIFPrice.Value), 2) : lstCost[2].Markup.Value;
                    decimal EditedFOBPrice2 = (lstCost[2].EditedFOBPrice != null && lstCost[2].EditedFOBPrice.Value != 0) ? lstCost[2].EditedFOBPrice.Value : (lstCost[2].IndimanCost != 0) ? Math.Round(((lstCost[2].IndimanCost.Value - o.ConvertionFactor.Value)) / (1 - (indicoCIFMarkup2 / 100)), 2) : 0;

                    decimal indicoCIFMarkup3 = (lstCost[3].EditedCIFPrice != null && lstCost[3].EditedCIFPrice != 0) ? Math.Round(100 - ((lstCost[3].IndimanCost.Value * 100) / lstCost[3].EditedCIFPrice.Value), 2) : lstCost[3].Markup.Value;
                    decimal EditedFOBPrice3 = (lstCost[3].EditedFOBPrice != null && lstCost[3].EditedFOBPrice.Value != 0) ? lstCost[3].EditedFOBPrice.Value : (lstCost[3].IndimanCost != 0) ? Math.Round(((lstCost[3].IndimanCost.Value - o.ConvertionFactor.Value)) / (1 - (indicoCIFMarkup3 / 100)), 2) : 0;

                    decimal indicoCIFMarkup4 = (lstCost[4].EditedCIFPrice != null && lstCost[4].EditedCIFPrice != 0) ? Math.Round(100 - ((lstCost[4].IndimanCost.Value * 100) / lstCost[4].EditedCIFPrice.Value), 2) : lstCost[4].Markup.Value;
                    decimal EditedFOBPrice4 = (lstCost[4].EditedFOBPrice != null && lstCost[4].EditedFOBPrice.Value != 0) ? lstCost[4].EditedFOBPrice.Value : (lstCost[4].IndimanCost != 0) ? Math.Round(((lstCost[4].IndimanCost.Value - o.ConvertionFactor.Value)) / (1 - (indicoCIFMarkup4 / 100)), 2) : 0;

                    decimal indicoCIFMarkup5 = (lstCost[5].EditedCIFPrice != null && lstCost[5].EditedCIFPrice != 0) ? Math.Round(100 - ((lstCost[5].IndimanCost.Value * 100) / lstCost[5].EditedCIFPrice.Value), 2) : lstCost[5].Markup.Value;
                    decimal EditedFOBPrice5 = (lstCost[5].EditedFOBPrice != null && lstCost[5].EditedFOBPrice.Value != 0) ? lstCost[5].EditedFOBPrice.Value : (lstCost[5].IndimanCost != 0) ? Math.Round(((lstCost[5].IndimanCost.Value - o.ConvertionFactor.Value)) / (1 - (indicoCIFMarkup5 / 100)), 2) : 0;

                    decimal indicoCIFMarkup6 = (lstCost[6].EditedCIFPrice != null && lstCost[6].EditedCIFPrice != 0) ? Math.Round(100 - ((lstCost[6].IndimanCost.Value * 100) / lstCost[6].EditedCIFPrice.Value), 2) : lstCost[6].Markup.Value;
                    decimal EditedFOBPrice6 = (lstCost[6].EditedFOBPrice != null && lstCost[6].EditedFOBPrice.Value != 0) ? lstCost[6].EditedFOBPrice.Value : (lstCost[6].IndimanCost != 0) ? Math.Round(((lstCost[6].IndimanCost.Value - o.ConvertionFactor.Value)) / (1 - (indicoCIFMarkup6 / 100)), 2) : 0;

                    decimal indicoCIFMarkup7 = (lstCost[7].EditedCIFPrice != null && lstCost[7].EditedCIFPrice != 0) ? Math.Round(100 - ((lstCost[7].IndimanCost.Value * 100) / lstCost[7].EditedCIFPrice.Value), 2) : lstCost[7].Markup.Value;
                    decimal EditedFOBPrice7 = (lstCost[7].EditedFOBPrice != null && lstCost[7].EditedFOBPrice.Value != 0) ? lstCost[7].EditedFOBPrice.Value : (lstCost[7].IndimanCost != 0) ? Math.Round(((lstCost[7].IndimanCost.Value - o.ConvertionFactor.Value)) / (1 - (indicoCIFMarkup7 / 100)), 2) : 0;


                    decimal calCIFPrice = (decimal)((100 * lstCost[0].IndimanCost) / (100 - lstCost[0].Markup));
                    decimal calFOBPrice = (decimal)((100 * (lstCost[0].IndimanCost - o.ConvertionFactor)) / (100 - lstCost[0].Markup));

                    //0
                    openxml_Excel.AddCellValueNumberFormat("G" + row.ToString(), (priceTerm == 1) ? ((!rbCalculatedPrice.Checked && lstCost[0].EditedCIFPrice != null) ? (lstCost[0].EditedCIFPrice.ToString()) : (((100 * lstCost[0].IndimanCost) / (100 - lstCost[0].Markup)).ToString()))
                        : ((!rbCalculatedPrice.Checked && lstCost[0].EditedFOBPrice != null) ? (EditedFOBPrice0.ToString()) : (((100 * (lstCost[0].IndimanCost - o.ConvertionFactor)) / (100 - lstCost[0].Markup)).ToString())), "Calibri", false, XLAlignmentHorizontalValues.Left, 11, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", XLColor.Orange);

                    //1
                    openxml_Excel.AddCellValueNumberFormat("H" + row.ToString(), (priceTerm == 1) ? ((!rbCalculatedPrice.Checked && lstCost[1].EditedCIFPrice != null) ? (lstCost[1].EditedCIFPrice.ToString()) : (((100 * lstCost[1].IndimanCost) / (100 - lstCost[1].Markup)).ToString()))
                        : ((!rbCalculatedPrice.Checked && lstCost[1].EditedFOBPrice != null) ? (EditedFOBPrice1.ToString()) : (((100 * (lstCost[1].IndimanCost - o.ConvertionFactor)) / (100 - lstCost[1].Markup)).ToString())), "Calibri", false, XLAlignmentHorizontalValues.Left, 11, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", XLColor.Orange);

                    //2
                    openxml_Excel.AddCellValueNumberFormat("I" + row.ToString(), (priceTerm == 1) ? ((!rbCalculatedPrice.Checked && lstCost[2].EditedCIFPrice != null) ? (lstCost[2].EditedCIFPrice.ToString()) : (((100 * lstCost[2].IndimanCost) / (100 - lstCost[2].Markup)).ToString()))
                        : ((!rbCalculatedPrice.Checked && lstCost[2].EditedFOBPrice != null) ? (EditedFOBPrice2.ToString()) : (((100 * (lstCost[2].IndimanCost - o.ConvertionFactor)) / (100 - lstCost[2].Markup)).ToString())), "Calibri", false, XLAlignmentHorizontalValues.Left, 11, "\"$\"#,##0.00;[Red]\"$\"#,##0.00", XLColor.Orange);

                    //3
                    openxml_Excel.AddCellValueNumberFormat("J" + row.ToString(), (priceTerm == 1) ? ((!rbCalculatedPrice.Checked && lstCost[3].EditedCIFPrice != null) ? (lstCost[3].EditedCIFPrice.ToString()) : (((100 * lstCost[3].IndimanCost) / (100 - lstCost[3].Markup)).ToString()))
                        : ((!rbCalculatedPrice.Checked && lstCost[3].EditedFOBPrice != null) ? (EditedFOBPrice3.ToString()) : (((100 * (lstCost[3].IndimanCost - o.ConvertionFactor)) / (100 - lstCost[3].Markup)).ToString())), "Calibri", false, XLAlignmentHorizontalValues.Left, 11, "\"$\"#,##0.00;[Red]\"$\"#,##0.00");

                    //4
                    openxml_Excel.AddCellValueNumberFormat("K" + row.ToString(), (priceTerm == 1) ? ((!rbCalculatedPrice.Checked && lstCost[4].EditedCIFPrice != null) ? (lstCost[4].EditedCIFPrice.ToString()) : (((100 * lstCost[4].IndimanCost) / (100 - lstCost[4].Markup)).ToString()))
                        : ((!rbCalculatedPrice.Checked && lstCost[4].EditedFOBPrice != null) ? (EditedFOBPrice4.ToString()) : (((100 * (lstCost[4].IndimanCost - o.ConvertionFactor)) / (100 - lstCost[4].Markup)).ToString())), "Calibri", false, XLAlignmentHorizontalValues.Left, 11, "\"$\"#,##0.00;[Red]\"$\"#,##0.00");
                    
                    //5
                    openxml_Excel.AddCellValueNumberFormat("L" + row.ToString(), (priceTerm == 1) ? ((!rbCalculatedPrice.Checked && lstCost[5].EditedCIFPrice != null) ? (lstCost[5].EditedCIFPrice.ToString()) : (((100 * lstCost[5].IndimanCost) / (100 - lstCost[5].Markup)).ToString()))
                        : ((!rbCalculatedPrice.Checked && lstCost[5].EditedFOBPrice != null) ? (EditedFOBPrice5.ToString()) : (((100 * (lstCost[5].IndimanCost - o.ConvertionFactor)) / (100 - lstCost[5].Markup)).ToString())), "Calibri", false, XLAlignmentHorizontalValues.Left, 11, "\"$\"#,##0.00;[Red]\"$\"#,##0.00");

                    //6
                    openxml_Excel.AddCellValueNumberFormat("M" + row.ToString(), (priceTerm == 1) ? ((!rbCalculatedPrice.Checked && lstCost[6].EditedCIFPrice != null) ? (lstCost[6].EditedCIFPrice.ToString()) : (((100 * lstCost[6].IndimanCost) / (100 - lstCost[6].Markup)).ToString()))
                        : ((!rbCalculatedPrice.Checked && lstCost[6].EditedFOBPrice != null) ? (EditedFOBPrice6.ToString()) : (((100 * (lstCost[6].IndimanCost - o.ConvertionFactor)) / (100 - lstCost[6].Markup)).ToString())), "Calibri", false, XLAlignmentHorizontalValues.Left, 11, "\"$\"#,##0.00;[Red]\"$\"#,##0.00");

                    //7
                    openxml_Excel.AddCellValueNumberFormat("N" + row.ToString(), (priceTerm == 1) ? ((!rbCalculatedPrice.Checked && lstCost[7].EditedCIFPrice != null) ? (lstCost[7].EditedCIFPrice.ToString()) : (((100 * lstCost[7].IndimanCost) / (100 - lstCost[7].Markup)).ToString()))
                        : ((!rbCalculatedPrice.Checked && lstCost[7].EditedFOBPrice != null) ? (EditedFOBPrice7.ToString()) : (((100 * (lstCost[7].IndimanCost - o.ConvertionFactor)) / (100 - lstCost[7].Markup)).ToString())), "Calibri", false, XLAlignmentHorizontalValues.Left, 11, "\"$\"#,##0.00;[Red]\"$\"#,##0.00");
                  
                    row++;
                    i++;

                    xlProgress = Math.Round(((double.Parse("100") / double.Parse(lstpr.Count.ToString())) * i), 0);

                    // Writing progress in text file.
                    /* string lines = xlProgress.ToString();
                     System.IO.StreamWriter file = new System.IO.StreamWriter(textFilePath, false);
                     file.WriteLine(lines);
                     file.Close();*/
                }
            }
            catch (Exception ex)
            {
                // Log the error
                IndicoLogging.log.Error("Error occured while Generation Label Excel.", ex);
            }
            finally
            {
                // Set AutoFilter colums
                openxml_Excel.AutotFilter("A6:F" + row.ToString());
                
                // Set Freeze Pane
                openxml_Excel.FreezePane(6, 6);

                // Save & Close the Excel Document
                openxml_Excel.CloseDocument(filePath);

                // release the lock
                IndicoPage.RWLock.ReleaseWriterLock();
            }
        }

        [WebMethod]
        public static string Progress(string UserID)
        {
            string percentage = "0";
            string textFilePath = IndicoConfiguration.AppConfiguration.PathToDataFolder + @"\Temp\progress_" + UserID + ".txt";

            if (File.Exists(textFilePath))
            {
                try
                {
                    using (StreamReader sr = new StreamReader(textFilePath))
                    {
                        try
                        {
                            percentage = sr.ReadToEnd();
                        }
                        catch (Exception ex)
                        {
                            // Log the error
                            IndicoLogging.log.Error("Error occured while reading file. " + textFilePath, ex);
                        }
                        finally
                        {
                            sr.Close();
                        }
                    }
                }
                catch { }
            }
            return percentage;
        }

        #endregion
    }
}