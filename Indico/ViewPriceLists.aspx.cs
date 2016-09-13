using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Linq.Dynamic;
using System.Transactions;

using Indico.BusinessObjects;
using Indico.Common;
using System.IO;
using System.Web.Services;

namespace Indico
{
    public partial class ViewPriceLists : IndicoPage
    {

        #region Fields

        private int onProgressCount = 0;

        #endregion

        #region Properties

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["ViewPrintersSortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "Name";
                }
                return sort;
            }
            set
            {
                ViewState["ViewPrintersSortExpression"] = value;
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

        protected void dgPriceLists_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            DataGridItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is ReturnDownloadPriceListViewBO)
            {
                ReturnDownloadPriceListViewBO objPriceList = (ReturnDownloadPriceListViewBO)item.DataItem;

                Literal lblType = (Literal)item.FindControl("lblType");
                if (objPriceList.Distributor > 0 && objPriceList.Label == 0)
                {
                    lblType.Text = "Distributor";
                }
                else if (objPriceList.Distributor == 0 && objPriceList.Label > 0)
                {
                    lblType.Text = "Label";
                }


                Literal litDistributor = (Literal)item.FindControl("litDistributor");
                litDistributor.Text = objPriceList.Name;

                Literal litPriceTerm = (Literal)item.FindControl("litPriceTerm");
                string price = (objPriceList.EditedPrice == true) ? "Edited Price" : "Calculated Price";
                litPriceTerm.Text = objPriceList.PriceTerm + "-" + price;

                // Designs
                Literal litDesigns = (Literal)item.FindControl("litDesigns");
                string creative = string.Empty;
                string studio = string.Empty;
                string thirdparty = string.Empty;

                if ((objPriceList.CreativeDesign != null))
                {
                    creative = "Creative  : $" + ((decimal)objPriceList.CreativeDesign).ToString("0.00");
                    litDesigns.Text = creative;
                }
                if (objPriceList.StudioDesign != null)
                {
                    studio = "Studio  : $" + ((decimal)objPriceList.StudioDesign).ToString("0.00");
                    litDesigns.Text = (litDesigns.Text != string.Empty) ? litDesigns.Text + ", " + studio : studio;
                }
                if (objPriceList.ThirdPartyDesign != null)
                {
                    thirdparty = "Third Party  : $" + ((decimal)objPriceList.ThirdPartyDesign).ToString("0.00");
                    litDesigns.Text = (litDesigns.Text != string.Empty) ? litDesigns.Text + ", " + thirdparty : thirdparty;
                }

                // Positions
                Literal litPositions = (Literal)item.FindControl("litPositions");
                string position1 = string.Empty;
                string position2 = string.Empty;
                string position3 = string.Empty;
                if (objPriceList.Position1 != null)
                {
                    position1 = "1: " + " $" + ((decimal)objPriceList.Position1).ToString("0.00");
                    litPositions.Text = position1;
                }
                if (objPriceList.Position2 != null)
                {
                    position2 = "2: " + "$" + ((decimal)objPriceList.Position2).ToString("0.00");
                    litPositions.Text = (litPositions.Text != string.Empty) ? litPositions.Text + ", " + position2 : position2;
                }
                if (objPriceList.Position3 != null)
                {
                    position3 = "3: " + "$" + ((decimal)objPriceList.Position3).ToString("0.00");
                    litPositions.Text = (litPositions.Text != string.Empty) ? litPositions.Text + ", " + position3 : position3;
                }

                Literal lblCreatedDate = (Literal)item.FindControl("lblCreatedDate");
                lblCreatedDate.Text = Convert.ToDateTime(objPriceList.CreatedDate).ToString("dd MMMM yyyy");

                Literal lblFileName = (Literal)item.FindControl("lblFileName");
                lblFileName.Text = (objPriceList.FileName != null) ? objPriceList.FileName.ToString() : string.Empty;

                Literal lblStatus = (Literal)item.FindControl("lblStatus");
                LinkButton linkDownload = (LinkButton)item.FindControl("linkDownload");

                HyperLink linkOnProgress = (HyperLink)item.FindControl("linkOnProgress");
                HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                if (objPriceList.Distributor > 0 && objPriceList.Label == 0)
                {
                    linkDelete.Attributes.Add("istype", "distributor");
                    linkDelete.Attributes.Add("qid", objPriceList.Distributor.ToString());

                }
                else if (objPriceList.Distributor == 0 && objPriceList.Label > 0)
                {
                    linkDelete.Attributes.Add("istype", "label");
                    linkDelete.Attributes.Add("qid", objPriceList.Label.ToString());
                }


                //linkDelete.Visible = false;

                string priceTermName = objPriceList.PriceTerm + " Price";

                string filePath = String.Format("{0}{1}", (IndicoConfiguration.AppConfiguration.PathToDataFolder + @"\PriceLists\"), objPriceList.FileName);

                FileInfo fi = null; FileStream fs = null;
                try
                {
                    fi = new FileInfo(filePath);
                    fs = fi.OpenRead();
                    fs.Close();

                    lblStatus.Text = "<span class=\"label label-" + "complete" + "\">" + "Completed" + "</span>";

                    if (objPriceList.Distributor > 0 && objPriceList.Label == 0)
                    {
                        linkDownload.Attributes.Add("istype", "distributor");
                        linkDownload.Attributes.Add("qid", objPriceList.Distributor.ToString());
                    }
                    else if (objPriceList.Distributor == 0 && objPriceList.Label > 0)
                    {
                        linkDownload.Attributes.Add("istype", "label");
                        linkDownload.Attributes.Add("qid", objPriceList.Label.ToString());
                    }

                    linkOnProgress.Visible = false;
                    linkDelete.Visible = false;
                    if (this.LoggedUserRoleName == GetUserRole(7) || this.LoggedUserRoleName == GetUserRole(5))
                    {
                        linkDelete.Visible = true;
                    }
                }
                catch (Exception)
                {
                    fi = null;
                    if (fs != null)
                    {
                        fs.Close();
                        fs = null;
                    }

                    lblStatus.Text = lblStatus.Text = "<span class=\"label label-" + "generating" + "\">" + "Generating..." + "</span>";
                    linkDownload.Visible = false;
                    linkDelete.Visible = false;

                    onProgressCount++;
                }

            }
        }

        protected void dgPriceLists_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        {
            // Set page index
            this.dgPriceLists.CurrentPageIndex = e.NewPageIndex;

            // Populate Downloads 
            this.PopulateDataGrid();
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int id = int.Parse(hdnSelectedID.Value);
            string type = this.hdnType.Value;

            if (type == "distributor")
            {
                PriceListDownloadsBO objPriceListDownload = new PriceListDownloadsBO(this.ObjContext);
                objPriceListDownload.ID = id;
                objPriceListDownload.GetObject();

                string filePath = String.Format("{0}{1}", (IndicoConfiguration.AppConfiguration.PathToDataFolder + @"\PriceLists\"), objPriceListDownload.FileName);

                if (File.Exists(filePath))
                {
                    File.Delete(filePath);

                    try
                    {
                        using (TransactionScope ts = new TransactionScope())
                        {
                            objPriceListDownload.Delete();
                            ObjContext.SaveChanges();
                            ts.Complete();
                        }
                    }
                    catch (Exception ex)
                    {

                        IndicoLogging.log.Error("Error occured while deleting distrinutor price list", ex);
                    }
                }
            }
            if (type == "label")
            {
                LabelPriceListDownloadsBO objLabelPriceListDownload = new LabelPriceListDownloadsBO(this.ObjContext);
                objLabelPriceListDownload.ID = id;
                objLabelPriceListDownload.GetObject();

                string filePath = String.Format("{0}{1}", (IndicoConfiguration.AppConfiguration.PathToDataFolder + @"\PriceLists\"), objLabelPriceListDownload.FileName);

                if (File.Exists(filePath))
                {
                    File.Delete(filePath);

                    try
                    {
                        using (TransactionScope ts = new TransactionScope())
                        {
                            objLabelPriceListDownload.Delete();
                            ObjContext.SaveChanges();
                            ts.Complete();
                        }
                    }
                    catch (Exception ex)
                    {

                        IndicoLogging.log.Error("Error occured while deleting label price list", ex);
                    }
                }
            }
            this.PopulateControls();

        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            this.PopulateDataGrid();
        }

        protected void btnDownload_Click(object sender, EventArgs e)
        {
            int downloadID = int.Parse(((System.Web.UI.WebControls.WebControl)(sender)).Attributes["qid"]);
            string type = ((System.Web.UI.WebControls.WebControl)(sender)).Attributes["istype"].ToString();
            string filePath = string.Empty;

            if (type == "distributor")
            {
                if (downloadID > 0)
                {
                    PriceListDownloadsBO objDownload = new PriceListDownloadsBO();
                    objDownload.ID = downloadID;
                    objDownload.GetObject();
                    filePath = String.Format("{0}{1}", (IndicoConfiguration.AppConfiguration.PathToDataFolder + @"\PriceLists\"), objDownload.FileName);

                }
            }

            if (type == "label")
            {
                if (downloadID > 0)
                {
                    LabelPriceListDownloadsBO objLabelDownload = new LabelPriceListDownloadsBO();
                    objLabelDownload.ID = downloadID;
                    objLabelDownload.GetObject();
                    filePath = String.Format("{0}{1}", (IndicoConfiguration.AppConfiguration.PathToDataFolder + @"\PriceLists\"), objLabelDownload.FileName);
                }
            }
            if (!string.IsNullOrEmpty(filePath))
            {
                while (true)
                {
                    if (File.Exists(filePath))
                    {
                        string[] attachFilePath = { filePath };
                        try
                        {
                            FileInfo fileInfo = new FileInfo(filePath);
                            string outputName = System.Text.RegularExpressions.Regex.Replace(fileInfo.Name, @"\W+", "_");
                            outputName = System.Text.RegularExpressions.Regex.Replace(outputName, "_xlsx", ".xlsx");
                            Response.ClearContent();
                            Response.ClearHeaders();
                            Response.AddHeader("Content-Type", "application/vnd.ms-excel");
                            Response.AddHeader("Content-Disposition", string.Format("attachment; filename = {0}", outputName));
                            Response.AddHeader("Content-Length", (fileInfo.Length).ToString("F0"));
                            Response.TransmitFile(filePath);
                            Response.Flush();
                            Response.Close();
                            Response.BufferOutput = true;
                            //Response.End();  
                        }
                        catch (Exception ex)
                        {
                            // Log the error
                            IndicoLogging.log.Error("Fail to download excel file.", ex);
                        }
                    }
                    break;
                }
            }
        }

        protected void btnPostBack_Click(object sender, EventArgs e)
        {
            string tempFile = IndicoConfiguration.AppConfiguration.PathToDataFolder + @"\Temp\progress_" + 1 + ".txt";
            if (File.Exists(tempFile))
            {
                File.Delete(tempFile);
            }
            this.PopulateDataGrid();
        }

        protected void ddlType_SelectedIndexChanged(object sender, EventArgs e)
        {
            this.PopulateDataGrid();
        }

        #endregion

        #region Methods

        /// <summary>
        /// Populate the controls.
        /// </summary>
        private void PopulateControls()
        {
            // Header Text
            this.litHeaderText.Text = this.ActivePage.Heading; //this.ActivePage.Heading;

            // Popup Header Text
            this.litHeaderText.Text = "Price Lists";

            ViewState["IsPageValied"] = true;


            this.PopulateDataGrid();
        }

        private void PopulateDataGrid()
        {
            // Populate Items        
            string searchText = this.txtSearch.Text.ToLower().Trim();
            List<ReturnDownloadPriceListViewBO> lstReturnDownloadPriceList = new List<ReturnDownloadPriceListViewBO>();


            if (!string.IsNullOrEmpty(searchText) && searchText != "search")
            {
                lstReturnDownloadPriceList = PriceListDownloadsBO.ReturnDownloadPriceList(0).Where(o => o.Name.ToLower().Trim() == searchText ||
                                                                                                       o.PriceTerm.ToLower().Trim() == searchText ||
                                                                                                       o.FileName.ToLower().Trim() == searchText).ToList();
            }
            else
            {
                lstReturnDownloadPriceList = PriceListDownloadsBO.ReturnDownloadPriceList(0).OrderByDescending(o => o.CreatedDate).ToList();
            }

            if (int.Parse(this.ddlType.SelectedValue) == 1)
            {
                lstReturnDownloadPriceList = PriceListDownloadsBO.ReturnDownloadPriceList(1).OrderByDescending(o => o.CreatedDate).ToList();
            }

            if (int.Parse(this.ddlType.SelectedValue) == 2)
            {
                lstReturnDownloadPriceList = PriceListDownloadsBO.ReturnDownloadPriceList(2).OrderByDescending(o => o.CreatedDate).ToList();
            }

            if (lstReturnDownloadPriceList.Count > 0)
            {
                this.dvEmptyContent.Visible = false;
                this.dvDataContent.Visible = true;
                this.dgPriceLists.AllowPaging = (lstReturnDownloadPriceList.Count > this.dgPriceLists.PageSize);
                this.dgPriceLists.DataSource = lstReturnDownloadPriceList;
                this.dgPriceLists.DataBind();
            }
            else if ((searchText != string.Empty && searchText != "search") || int.Parse(this.ddlType.SelectedItem.Value) != 0)
            {
                //this.lblSerchKey.Text = searchText + ((searchText != string.Empty) ? " - " : string.Empty) + "Filter by " + this.ddlSortByGarmentSpec.SelectedItem.Text;
                this.dvDataContent.Visible = true;
                this.dgPriceLists.Visible = false; //(lstReturnDownloadPriceList.Count > 0);
                this.dvNoSearchResult.Visible = true;
                this.dgPriceLists.Visible = true;
            }
            else
            {
                this.dvDataContent.Visible = true;
                this.dgPriceLists.Visible = false; //(lstReturnDownloadPriceList.Count > 0);
                this.dvemptyresult.Visible = true;

            }
            if (onProgressCount > 2)
            {
                this.btnDownload.Visible = false;
            }
        }

        [WebMethod]
        public static string Progress(string UserID)
        {
            string percentage = "0";
            string textFilePath = IndicoConfiguration.AppConfiguration.PathToDataFolder + @"\Temp\progress_" + 1 + ".txt";

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