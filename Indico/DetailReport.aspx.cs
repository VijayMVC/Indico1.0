using System;
using System.Collections.Generic;
using System.IO;
using System.Drawing;
using System.Linq;
using System.Linq.Dynamic;
using System.Transactions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;

using Indico.Common;
using Indico.BusinessObjects;
using System.Text.RegularExpressions;
using Microsoft.Reporting.WebForms;
using System.Threading;
using System.Reflection;

namespace Indico
{
    public partial class DetailReport : IndicoPage
    {
        #region Fields

        #endregion

        #region Properties

        public bool IsNotRefreshed
        {
            get
            {
                return (Session["IsPostBack"].ToString() == ViewState["IsPostBack"].ToString());
            }
        }


        #endregion

        #region Constructors

        #endregion

        #region Events

        protected override void OnPreRender(EventArgs e)
        {
            base.OnPreRender(e);
            DisableUnwantedExportFormat(this.rvSalesReport, "Excel");
            DisableUnwantedExportFormat(this.rvSalesReport, "Word");
        }

        /// <summary>
        /// Page load event
        /// </summary>
        /// <param name="sender">Sender</param>
        /// <param name="e">Even arg</param>
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!this.IsPostBack)
            {
                PopulateControls();
            }
        }

        protected void ddlDistributor_SelectedIndexChanged(object sender, EventArgs e)
        {
           
        }

        protected void btnViewReport_OnClick(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                try
                {
                    DateTime? selecteddate1 = null;
                    DateTime? selecteddate2 = null;

                    if (!string.IsNullOrEmpty(this.txtCheckin.Value) && !string.IsNullOrEmpty(this.txtCheckout.Value))
                    {
                        selecteddate1 = Convert.ToDateTime(this.txtCheckin.Value);
                        selecteddate2 = Convert.ToDateTime(this.txtCheckout.Value);
                    }

                    this.rvSalesReport.ShowToolBar = true;
                    this.rvSalesReport.ShowRefreshButton = false;
                    //this.rvSalesReport.ShowExportControls = false;
                    this.rvSalesReport.SizeToReportContent = true;
                    this.rvSalesReport.ProcessingMode = Microsoft.Reporting.WebForms.ProcessingMode.Local;
                    this.rvSalesReport.LocalReport.ReportPath = Server.MapPath("~/Reports/Report2.rdl");
                    this.rvSalesReport.Visible = true;
                    ReportDataSource dataSource = new ReportDataSource("DataSet1", OrderBO.GetDetailReportForDistributorForGivenDateRange(selecteddate1, selecteddate2, int.Parse(this.ddlDistributor.SelectedItem.Value)));
                    this.rvSalesReport.LocalReport.DataSources.Clear();
                    this.rvSalesReport.LocalReport.DataSources.Add(dataSource);
                }
                catch (Exception ex)
                { 
                }
            }
            
                this.validationSummary.Visible = !Page.IsValid;
        }

        protected void btnPrintReport_OnClick(object sender, EventArgs e)
        {
            /*using (ReportViewer rpt = new ReportViewer())
            {
                bool IsFileOpen = false;
                string reportName = "SalesReport" + DateTime.Now.Ticks.ToString();
               // string dataFolder = @"~\IndicoData\Temp";
                //string rdlFileName = "Sales Report";

               // rpt.ProcessingMode = ProcessingMode.Local;
               // rpt.LocalReport.ReportPath = Server.MapPath("~/Reports/Report1.rdl");

                DateTime? selecteddate1 = null;
                DateTime? selecteddate2 = null;

                if (!string.IsNullOrEmpty(this.txtCheckin.Value) && !string.IsNullOrEmpty(this.txtCheckout.Value))
                {
                    selecteddate1 = Convert.ToDateTime(this.txtCheckin.Value);
                    selecteddate2 = Convert.ToDateTime(this.txtCheckout.Value);
                }

                rpt.ShowToolBar = false;
                rpt.SizeToReportContent = true;
                rpt.ProcessingMode = Microsoft.Reporting.WebForms.ProcessingMode.Local;
                rpt.LocalReport.ReportPath = Server.MapPath("~/Reports/Report1.rdl");
                rpt.Visible = true;
                ReportDataSource dataSource = new ReportDataSource("DataSet1", OrderBO.GetOrderQuantitiesAndAmountForDistributorsForGivenDateRange(selecteddate1, selecteddate2, /*int.Parse(this.ddlDistributor.SelectedItem.Value)*/// this.txtName.Text, this.rdoDirectSales.Checked ? 1 : 2));
                /*rpt.LocalReport.DataSources.Clear();
                rpt.LocalReport.DataSources.Add(dataSource);

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
            }*/
        }

        protected void cvDateRange_ServerValidate(object source, ServerValidateEventArgs args)
        {
            try
            {
                DateTime? selecteddate1 = null;
                DateTime? selecteddate2 = null;

                if (!string.IsNullOrEmpty(this.txtCheckin.Value) && !string.IsNullOrEmpty(this.txtCheckout.Value))
                {
                    selecteddate1 = Convert.ToDateTime(this.txtCheckin.Value);
                    selecteddate2 = Convert.ToDateTime(this.txtCheckout.Value);
                }

                this.cvDateRange.IsValid = selecteddate1 < selecteddate2;
            }
            catch (Exception ex)
            {
                this.cvDateRange.IsValid = false;
            }
        }

        #endregion

        #region Methods

        /// <summary>
        /// This method calls when page loads
        /// </summary>
        private void PopulateControls()
        {
            this.litHeaderText.Text = "Detail Report";

            CompanyBO objDistributor = new CompanyBO();
            objDistributor.IsDistributor = true;
            List<CompanyBO> lstDist = objDistributor.SearchObjects().OrderBy(m => m.Name).ToList();

            ddlDistributor.Items.Clear();
            ddlDistributor.Items.Add(new ListItem("Select Distributor", "0"));
            foreach (CompanyBO dist in lstDist)
            {
                ddlDistributor.Items.Add(new ListItem(dist.Name, dist.ID.ToString()));
            }
        }

        private void ProcessForm()
        {

        }

        public void DisableUnwantedExportFormat(ReportViewer ReportViewerID, string strFormatName)
        {
            FieldInfo info;

            foreach (RenderingExtension extension in ReportViewerID.LocalReport.ListRenderingExtensions())
            {
                if (extension.Name == strFormatName)
                {
                    info = extension.GetType().GetField("m_isVisible", BindingFlags.Instance | BindingFlags.NonPublic);
                    info.SetValue(extension, false);
                }
            }
        }

        #endregion
    }
}