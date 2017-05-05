using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI.WebControls;
using Indico.Common;
using Indico.BusinessObjects;
using System.Transactions;
using Telerik.Web.UI;
using Microsoft.Reporting.WebForms;
using DB = Indico.Providers.Data.DapperProvider;
using System.IO;
using System.Threading;

namespace Indico
{
    public partial class ViewInvoices : IndicoPage
    {
        #region Field

        private int urlWeeklyID = -1;

        #endregion

        #region Properties

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["InvoiceSortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "InvoiceNo";
                }
                return sort;
            }
            set
            {
                ViewState["InvoiceSortExpression"] = value;
            }
        }

        protected int WeeklyCapacityID
        {
            get
            {
                if (urlWeeklyID > -1)
                    return urlWeeklyID;

                urlWeeklyID = 0;
                if (Request.QueryString["wid"] != null)
                {
                    urlWeeklyID = Convert.ToInt32(Request.QueryString["wid"].ToString());
                }
                return urlWeeklyID;
            }
        }

        #endregion

        #region Constructors

        #endregion

        #region Event

        protected void OnPreRender(object sender, EventArgs e)
        {
            Session["IsPostBack"] = Server.UrlEncode(Guid.NewGuid().ToString());
            ViewState["IsPostBack"] = Session["IsPostBack"];
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                PopulateControls();
            }
        }

        protected void RadInvoice_ItemCommand(object sender, Telerik.Web.UI.GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                ReBindGrid();
            }
        }

        protected void RadInvoice_ItemDataBound(object sender, Telerik.Web.UI.GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if ((item.ItemIndex > -1 && item.DataItem is ReturnInvoiceDetailsBO))
                {
                    ReturnInvoiceDetailsBO objInvoice = (ReturnInvoiceDetailsBO)item.DataItem;

                    HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
                    linkEdit.NavigateUrl = "/AddEditInvoice.aspx?id=" + objInvoice.Invoice.ToString();

                    //decimal totalfactoryprice = 0;


                    //totalfactoryprice = (decimal)(objInvoice.Qty * objInvoice.FactoryRate);


                    //Literal litAmount = (Literal)item.FindControl("litAmount");
                    //litAmount.Text = totalfactoryprice.ToString("0.00");

                    LinkButton btnInvoiceDetail = (LinkButton)item.FindControl("btnInvoiceDetail");
                    btnInvoiceDetail.Attributes.Add("qid", objInvoice.Invoice.ToString());
                    //btnInvoiceDetail.CommandName = "InvoiceDetail";

                    LinkButton btnInvoiceSummary = (LinkButton)item.FindControl("btnInvoiceSummary");
                    btnInvoiceSummary.Attributes.Add("qid", objInvoice.Invoice.ToString());

                    LinkButton btnCombineInvoice = (LinkButton)item.FindControl("btnCombineInvoice");
                    btnCombineInvoice.Attributes.Add("qid", objInvoice.Invoice.ToString());

                    Literal litStatus = (Literal)item.FindControl("litStatus");
                    litStatus.Text = "<span class=\"label label-" + objInvoice.Status.ToLower().Replace(" ", string.Empty).Trim() + "\">" + objInvoice.Status + "</span>";

                }
            }
        }

        protected void RadInvoice_PageIndexChanged(object sender, Telerik.Web.UI.GridPageChangedEventArgs e)
        {
            ReBindGrid();
        }

        protected void RadInvoice_SortCommand(object sender, Telerik.Web.UI.GridSortCommandEventArgs e)
        {
            ReBindGrid();
        }

        protected void HeaderContextMenu_ItemCLick(object sender, RadMenuEventArgs e)
        {
            ReBindGrid();
        }

        protected void RadInvoice_GroupsChanging(object sender, GridGroupsChangingEventArgs e)
        {
            ReBindGrid();
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            PopulateDataGrid();
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int invoiceID = int.Parse(hdnSelectedID.Value.Trim());

            if (invoiceID > 0)
            {
                try
                {
                    using (TransactionScope ts = new TransactionScope())
                    {
                        InvoiceBO objInvoice = new InvoiceBO(ObjContext);
                        objInvoice.ID = invoiceID;
                        objInvoice.GetObject();

                        List<InvoiceOrderBO> lstInvoiceOrder = (new InvoiceOrderBO()).GetAllObject().Where(o => o.Invoice == objInvoice.ID).ToList();
                        foreach (InvoiceOrderBO objDelInvoiceOrder in lstInvoiceOrder)
                        {
                            InvoiceOrderBO objInvoiceOrder = new InvoiceOrderBO(ObjContext);
                            objInvoiceOrder.ID = objDelInvoiceOrder.ID;
                            objInvoiceOrder.GetObject();

                            objInvoiceOrder.Delete();

                        }

                        objInvoice.Delete();
                        ObjContext.SaveChanges();
                        ts.Complete();
                    }
                }
                catch (Exception ex)
                {
                    throw ex;
                }
                PopulateDataGrid();
            }

        }

        protected void btnPrintInvoiceDetail_Click(object sender, EventArgs e)
        {
            int id = int.Parse(((System.Web.UI.WebControls.WebControl)(sender)).Attributes["qid"].ToString());

            using (ReportViewer rpt = new ReportViewer())
            {
                bool IsFileOpen = false;
                string reportName = "JK_Detail_Invoice" + DateTime.Now.Ticks.ToString();
                //string dataFolder = @"~\IndicoData\Temp";
                //string rdlFileName = "Sales Report";

                //rpt.ProcessingMode = ProcessingMode.Local;
                //rpt.LocalReport.ReportPath = Server.MapPath("~/Reports/JK_Detail_Invoice.rdl");

                //DateTime? selecteddate1 = null;
                //DateTime? selecteddate2 = null;

                //if (!string.IsNullOrEmpty(this.txtCheckin.Value) && !string.IsNullOrEmpty(this.txtCheckout.Value))
                //{
                //    selecteddate1 = Convert.ToDateTime(this.txtCheckin.Value);
                //    selecteddate2 = Convert.ToDateTime(this.txtCheckout.Value);
                //}

                rpt.ShowToolBar = false;
                rpt.SizeToReportContent = true;
                rpt.ProcessingMode = Microsoft.Reporting.WebForms.ProcessingMode.Local;
                rpt.LocalReport.ReportPath = Server.MapPath("~/Reports/JK_Detail_Invoice.rdl");
                rpt.Visible = true;

                List<ReportParameter> parameters = new List<ReportParameter>();
                ReportParameter parameter = new ReportParameter();
                parameter.Name = "P_InvoiceId";
                parameter.Values.Add(id.ToString());
                parameters.Add(parameter);
                rpt.LocalReport.SetParameters(parameters);

                ReportDataSource dataSource = new ReportDataSource("DataSet1", DB.GetJKDetailInvoiceInfo(id));

                rpt.LocalReport.DataSources.Clear();
                rpt.LocalReport.DataSources.Add(dataSource);
                rpt.LocalReport.Refresh();

                string mimeType, encoding, extension, deviceInfo;
                string[] streamids;
                Warning[] warnings;
                string format = "PDF";

                deviceInfo = "<DeviceInfo>" + "<SimplePageHeaders>True</SimplePageHeaders>" + "</DeviceInfo>";

                byte[] bytes = rpt.LocalReport.Render(format, deviceInfo, out mimeType, out encoding, out extension, out streamids, out warnings);

                string temppath = IndicoConfiguration.AppConfiguration.PathToDataFolder + @"\Temp\" + reportName + ".pdf";

                FileStream stream = null;

                if (File.Exists(temppath))
                {
                    try
                    {
                        stream = File.Open(temppath, FileMode.Open, FileAccess.ReadWrite, FileShare.None);
                    }
                    catch (IOException)
                    {

                        IsFileOpen = true;
                    }
                    finally
                    {
                        if (stream != null)
                            stream.Close();
                    }
                }

                if (File.Exists(temppath) && !IsFileOpen)
                {
                    File.Delete(temppath);
                }

                if (!IsFileOpen)
                {
                    using (FileStream fs = new FileStream(temppath, FileMode.Create))
                    {
                        fs.Write(bytes, 0, bytes.Length);
                    }
                }

                while (File.Exists(temppath))
                {
                    Thread.Sleep(1000);
                    System.Diagnostics.Process.Start(temppath);
                    break;
                }

                if (File.Exists(temppath))
                {
                    try
                    {
                        this.DownloadPDFFile(temppath);
                    }
                    catch (Exception ex)
                    {
                        IndicoLogging.log.Error("Error occured while printing JKInvoiceOrderDetail from AddEditInvoice.aspx", ex);
                    }
                }
            }
        }

        protected void btnPrintInvoiceSummary_Click(object sender, EventArgs e)
        {
            int id = int.Parse(((System.Web.UI.WebControls.WebControl)(sender)).Attributes["qid"].ToString());

            using (ReportViewer rpt = new ReportViewer())
            {
                bool IsFileOpen = false;
                string reportName = "JK_HSCode_Summary" + DateTime.Now.Ticks.ToString();
                //string dataFolder = @"~\IndicoData\Temp";
                //string rdlFileName = "Sales Report";

                //rpt.ProcessingMode = ProcessingMode.Local;
                //rpt.LocalReport.ReportPath = Server.MapPath("~/Reports/JK_Detail_Invoice.rdl");

                //DateTime? selecteddate1 = null;
                //DateTime? selecteddate2 = null;

                //if (!string.IsNullOrEmpty(this.txtCheckin.Value) && !string.IsNullOrEmpty(this.txtCheckout.Value))
                //{
                //    selecteddate1 = Convert.ToDateTime(this.txtCheckin.Value);
                //    selecteddate2 = Convert.ToDateTime(this.txtCheckout.Value);
                //}

                rpt.ShowToolBar = false;
                rpt.SizeToReportContent = true;
                rpt.ProcessingMode = Microsoft.Reporting.WebForms.ProcessingMode.Local;
                rpt.LocalReport.ReportPath = Server.MapPath("~/Reports/JK_HSCode_Summary.rdl");
                rpt.Visible = true;

                List<ReportParameter> parameters = new List<ReportParameter>();
                ReportParameter parameter = new ReportParameter();
                parameter.Name = "P_InvoiceId";
                parameter.Values.Add(id.ToString());
                parameters.Add(parameter);
                rpt.LocalReport.SetParameters(parameters);

                ReportDataSource dataSource = new ReportDataSource("DataSet1", DB.GetJKDetailSummeryInvoiceInfo(id));

                rpt.LocalReport.DataSources.Clear();
                rpt.LocalReport.DataSources.Add(dataSource);
                rpt.LocalReport.Refresh();

                string mimeType, encoding, extension, deviceInfo;
                string[] streamids;
                Warning[] warnings;
                string format = "PDF";

                deviceInfo = "<DeviceInfo>" + "<SimplePageHeaders>True</SimplePageHeaders>" + "</DeviceInfo>";

                byte[] bytes = rpt.LocalReport.Render(format, deviceInfo, out mimeType, out encoding, out extension, out streamids, out warnings);

                string temppath = IndicoConfiguration.AppConfiguration.PathToDataFolder + @"\Temp\" + reportName + ".pdf";

                FileStream stream = null;

                if (File.Exists(temppath))
                {
                    try
                    {
                        stream = File.Open(temppath, FileMode.Open, FileAccess.ReadWrite, FileShare.None);
                    }
                    catch (IOException)
                    {

                        IsFileOpen = true;
                    }
                    finally
                    {
                        if (stream != null)
                            stream.Close();
                    }
                }

                if (File.Exists(temppath) && !IsFileOpen)
                {
                    File.Delete(temppath);
                }

                if (!IsFileOpen)
                {
                    using (FileStream fs = new FileStream(temppath, FileMode.Create))
                    {
                        fs.Write(bytes, 0, bytes.Length);
                    }
                }

                while (File.Exists(temppath))
                {
                    Thread.Sleep(1000);
                    System.Diagnostics.Process.Start(temppath);
                    break;
                }

                if (File.Exists(temppath))
                {
                    try
                    {
                        this.DownloadPDFFile(temppath);
                    }
                    catch (Exception ex)
                    {
                        IndicoLogging.log.Error("Error occured while printing JKInvoiceOrderDetail from AddEditInvoice.aspx", ex);
                    }
                }
            }
        }

        //protected void btnInvoiceDetail_Click(object sender, EventArgs e)
        //{
        //    int id = int.Parse(((System.Web.UI.WebControls.WebControl)(sender)).Attributes["qid"].ToString());
        //    //int id = int.Parse(hdnSelectedID.Value);

        //    if (id > 0)
        //    {
        //        try
        //        {
        //            string pdfFilePath = Common.GenerateOdsPdf.GenerateJKInvoiceDetail(id);

        //            DownloadPDFFile(pdfFilePath);
        //        }
        //        catch (Exception ex)
        //        {
        //            IndicoLogging.log.Error("Error occured while printing JKInvoiceOrderDetail from ViewInvoices.aspx", ex);
        //        }
        //    }
        //}

        //protected void btnPrintInvoiceSummary_Click(object sender, EventArgs e)
        //{
        //    int id = int.Parse(((System.Web.UI.WebControls.WebControl)(sender)).Attributes["qid"].ToString());
        //    //int id = int.Parse(hdnSelectedID.Value);

        //    if (id > 0)
        //    {
        //        try
        //        {
        //            string pdfFilePath = Common.GenerateOdsPdf.GenerateJKInvoiceSummary(id);

        //            DownloadPDFFile(pdfFilePath);
        //        }
        //        catch (Exception ex)
        //        {
        //            IndicoLogging.log.Error("Error occured while printing JKInvoiceSummary from ViewInvoices.aspx", ex);
        //        }
        //    }
        //}

        protected void btnCombineInvoice_Click(object sender, EventArgs e)
        {
            int id = int.Parse(((System.Web.UI.WebControls.WebControl)(sender)).Attributes["qid"].ToString());
            //int id = int.Parse(hdnSelectedID.Value);

            if (id > 0)
            {
                try
                {
                    string pdfFilePath = Common.GenerateOdsPdf.CombinedInvoice(id);

                    DownloadPDFFile(pdfFilePath);
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while printing JKCombineInvoice from ViewInvoices.aspx", ex);
                }
            }
        }

        /*protected void btnIndimanInvoice_Click(object sender, EventArgs e)
        {
            int id = int.Parse(hdnSelectedID.Value);

            if (id > 0)
            {
                try
                {
                    string pdfFilePath = Common.GenerateOdsPdf.GenerateIndimanInvoice(id);

                    DownloadPDFFile(pdfFilePath);
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while printing Indiman Invoice from ViewInvoices.aspx", ex);
                }
            }
        }*/

        #endregion

        #region Methods

        private void PopulateControls()
        {
            // Header Text
            litHeaderText.Text = ActivePage.Heading;
            PopulateDataGrid();
        }

        //private void PopulateDataGrid()
        //{
        //    // Hide Controls
        //    dvEmptyContent.Visible = false;
        //    dvDataContent.Visible = false;
        //    dvNoSearchResult.Visible = false;

        //    // Search text
        //    string searchText = txtSearchInvoiceNo.Text.ToLower().Trim();

        //    // Populate Items
        //    List<ReturnInvoiceDetailsBO> lstInvoice = new List<ReturnInvoiceDetailsBO>();
        //    if ((searchText != string.Empty) && (searchText != "search"))
        //    {
        //        lstInvoice = (new ReturnInvoiceDetailsBO()).SearchObjects().Where(o => o.InvoiceNo.ToLower().Contains(searchText) ||
        //                                                                          o.ShipmentMode.ToLower().Contains(searchText) ||
        //                                                                          o.ShipTo.ToLower().Contains(searchText) ||
        //                                                                          o.AWBNo.ToLower().Contains(searchText) ||
        //                                                                          o.IndimanInvoiceNo.ToLower().Contains(searchText)).ToList();
        //    }
        //    else
        //    {
        //        lstInvoice = (new ReturnInvoiceDetailsBO()).SearchObjects().OrderByDescending(o => o.Invoice).ToList();
        //    }

        //    if (WeeklyCapacityID > 0)
        //    {
        //        lstInvoice = lstInvoice.Where(o => o.WeeklyProductionCapacity == WeeklyCapacityID).ToList();
        //    }

        //    if (lstInvoice.Count > 0)
        //    {
        //        RadInvoice.AllowPaging = (lstInvoice.Count > RadInvoice.PageSize);
        //        RadInvoice.DataSource = lstInvoice;
        //        RadInvoice.DataBind();

        //        dvDataContent.Visible = true;

        //        Session["Invoice"] = lstInvoice;
        //    }
        //    else if ((searchText != string.Empty && searchText != "search"))
        //    {
        //        lblSerchKey.Text = searchText + ((searchText != string.Empty) ? " - " : string.Empty);

        //        dvDataContent.Visible = true;
        //        dvNoSearchResult.Visible = true;
        //    }
        //    else
        //    {
        //        dvEmptyContent.Visible = true;
        //        btnAddInvoice.Visible = false;
        //    }

        //    RadInvoice.Visible = (lstInvoice.Count > 0);
        //}

        private void ReBindGrid()
        {
            if (Session["Invoice"] != null)
            {
                InvoiceGrid.DataSource = (List<ReturnInvoiceDetailsBO>)Session["Invoice"];
                InvoiceGrid.DataBind();
            }
        }

        #endregion

    }
}