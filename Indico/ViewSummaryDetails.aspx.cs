using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Transactions;

using Indico.BusinessObjects;
using Indico.Common;
using Telerik.Web.UI;

namespace Indico
{
    public partial class ViewSummaryDetails : IndicoPage
    {
        #region Fields

        private DateTime qpWeekEndDate = new DateTime(1100, 1, 1);
        private int total = 0;

        #endregion

        #region Properties

        protected DateTime WeekEndDate
        {
            get
            {
                //if (qpWeekEndDate != new DateTime(1100, 1, 1))
                //    return qpWeekEndDate;
                if (Request.QueryString["WeekendDate"] != null)
                {
                    qpWeekEndDate = Convert.ToDateTime(Request.QueryString["WeekendDate"].ToString());
                }
                return qpWeekEndDate;
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

        protected void Page_PreRender(EventArgs e)
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

        //protected void dgWeeklySummary_ItemDataBound(object sender, DataGridItemEventArgs e)
        //{
        //    DataGridItem item = e.Item;
        //    // total = 0;
        //    if (item.ItemIndex > -1 && item.DataItem is ReturnWeeklySummaryViewBO)
        //    {
        //        ReturnWeeklySummaryViewBO objWeekSummary = (ReturnWeeklySummaryViewBO)item.DataItem;

        //        Literal litWeekEnDate = (Literal)item.FindControl("litWeekEnDate");
        //        litWeekEnDate.Text = this.WeekEndDate.ToString("dd MMMM yyyy");

        //        Literal litShipmentMode = (Literal)item.FindControl("litShipmentMode");
        //        litShipmentMode.Text = objWeekSummary.ShipmentMode;

        //        Literal litShipTo = (Literal)item.FindControl("litShipTo");
        //        litShipTo.Text = objWeekSummary.CompanyName;

        //        HyperLink linkTotal = (HyperLink)item.FindControl("linkTotal");
        //        linkTotal.Text = objWeekSummary.Qty.ToString();
        //        linkTotal.NavigateUrl = "ViewWeekDetails.aspx?WeekendDate=" + this.WeekEndDate.ToString("dd/MM/yyyy") + "&CompanyName=" + objWeekSummary.CompanyName + "&sm=" + objWeekSummary.ShipmentModeID;

        //        TextBox txtInvoiceNo = (TextBox)item.FindControl("txtInvoiceNo");

        //        string invno = (new InvoiceBO()).SearchObjects().Where(o => o.ShipmentDate == objWeekSummary.ShipmentDate && o.ShipmentMode == objWeekSummary.ShipmentModeID && o.ShipTo == objWeekSummary.DistributorClientAddress).Select(o => o.InvoiceNo).SingleOrDefault();

        //        LinkButton btnCreateInvoice = (LinkButton)item.FindControl("btnCreateInvoice");
        //        btnCreateInvoice.Attributes.Add("widdate", this.WeekEndDate.ToString("dd MMMM yyyy"));
        //        btnCreateInvoice.Attributes.Add("sdate", Convert.ToDateTime(objWeekSummary.ShipmentDate.ToString()).ToString("dd MMMM yyyy"));
        //        btnCreateInvoice.Attributes.Add("smkey", objWeekSummary.DistributorClientAddress.ToString());
        //        btnCreateInvoice.Attributes.Add("smid", objWeekSummary.ShipmentModeID.ToString());

        //        if (!string.IsNullOrEmpty(invno))
        //        {
        //            txtInvoiceNo.Text = invno;
        //            txtInvoiceNo.Enabled = false;
        //            btnCreateInvoice.Visible = false;
        //        }

        //        total = total + (int)objWeekSummary.Qty;
        //    }
        //}

        protected void RadGridWeeklySummary_PageSizeChanged(object sender, Telerik.Web.UI.GridPageSizeChangedEventArgs e)
        {
            ReBindGrid();
        }

        protected void RadGridWeeklySummary_PageIndexChanged(object sender, Telerik.Web.UI.GridPageChangedEventArgs e)
        {
            ReBindGrid();
        }

        protected void RadGridWeeklySummary_ItemDataBound(object sender, Telerik.Web.UI.GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if (item.ItemIndex > -1 && item.DataItem is ReturnWeeklySummaryViewBO)
                {
                    ReturnWeeklySummaryViewBO objWeekSummary = (ReturnWeeklySummaryViewBO)item.DataItem;

                    Literal litWeekEnDate = (Literal)item.FindControl("litWeekEnDate");
                    litWeekEnDate.Text = this.WeekEndDate.ToString("dd MMMM yyyy");

                    HyperLink linkTotal = (HyperLink)item.FindControl("linkTotal");
                    linkTotal.Text = objWeekSummary.Qty.ToString();
                    linkTotal.NavigateUrl = "ViewWeekDetails.aspx?WeekendDate=" + this.WeekEndDate.ToString("dd/MM/yyyy") + "&CompanyName=" + objWeekSummary.CompanyName + "&sm=" + objWeekSummary.ShipmentModeID;

                    TextBox txtInvoiceNo = (TextBox)item.FindControl("txtInvoiceNo");

                   

                    Literal litStatus = (Literal)item.FindControl("litStatus");
                    litStatus.Text = "<span class=\"label label-" + objWeekSummary.InvoiceStatus.ToLower().Replace(" ", string.Empty).Trim() + "\">" + objWeekSummary.InvoiceStatus + "</span>";

                    HyperLink linkInvoice = (HyperLink)item.FindControl("linkInvoice");
                    linkInvoice.NavigateUrl = "AddEditInvoice.aspx?id=" + objWeekSummary.Invoice.ToString();
                    linkInvoice.Visible = (objWeekSummary.Invoice > 0) ? true : false;

                    LinkButton btnCreateInvoice = (LinkButton)item.FindControl("btnCreateInvoice");
                    btnCreateInvoice.Attributes.Add("widdate", this.WeekEndDate.ToString("dd MMMM yyyy"));
                    btnCreateInvoice.Attributes.Add("sdate", Convert.ToDateTime(objWeekSummary.ShipmentDate.ToString()).ToString("dd MMMM yyyy"));
                    btnCreateInvoice.Attributes.Add("smkey", objWeekSummary.DistributorClientAddress.ToString());
                    btnCreateInvoice.Attributes.Add("smid", objWeekSummary.ShipmentModeID.ToString());

                     if (objWeekSummary.Invoice > 0)
                    {
                        InvoiceBO objInvoice = new InvoiceBO();
                        objInvoice.ID = (int)objWeekSummary.Invoice;
                        objInvoice.GetObject();

                        txtInvoiceNo.Text = objInvoice.InvoiceNo;
                        txtInvoiceNo.Enabled = false;
                        btnCreateInvoice.Visible = false;
                    }
                   

                    total = total + (int)objWeekSummary.Qty;
                }
            }
            else if (e.Item is GridFooterItem)
            {
                var item = e.Item as GridFooterItem;


                Literal litQty = (Literal)item.FindControl("litQty");
                litQty.Text = total.ToString();
            }            
        }

        protected void RadGridWeeklySummary_ItemCommand(object sender, Telerik.Web.UI.GridCommandEventArgs e)
        {
            ReBindGrid();
        }

        protected void RadGridWeeklySummary_SortCommand(object sender, Telerik.Web.UI.GridSortCommandEventArgs e)
        {
            ReBindGrid();
        }

        protected void btnCreateInvoice_Click(object sender, EventArgs e)
        {
            string weekenddate = ((System.Web.UI.WebControls.WebControl)(sender)).Attributes["widdate"].ToString();
            string sdate = ((System.Web.UI.WebControls.WebControl)(sender)).Attributes["sdate"].ToString();
            string smkey = ((System.Web.UI.WebControls.WebControl)(sender)).Attributes["smkey"].ToString();
            string smid = ((System.Web.UI.WebControls.WebControl)(sender)).Attributes["smid"].ToString();

            TextBox txtInvoiceNo = (TextBox)((LinkButton)(sender)).FindControl("txtInvoiceNo");

            string invoiceno = txtInvoiceNo.Text;

            if (!string.IsNullOrEmpty(weekenddate) && !string.IsNullOrEmpty(sdate) && !string.IsNullOrEmpty(smkey) && !string.IsNullOrEmpty(invoiceno) && !string.IsNullOrEmpty(smid))
            {
                Response.Redirect("/AddEditInvoice.aspx?widdate=" + weekenddate + "&sdate=" + sdate + "&smkey=" + smkey + "&invno=" + invoiceno + "&smid=" + smid);
            }
        }

        protected void HeaderContextMenu_ItemCLick(object sender, EventArgs e)
        {
            this.ReBindGrid();
        }

        #endregion

        #region Methods

        /// <summary>
        /// Populate the controls.
        /// </summary>
        private void PopulateControls()
        {
            this.litHeaderText.Text = this.ActivePage.Heading;

            this.PopulateDataGrid();

        }

        private void PopulateDataGrid()
        {
            {
                // Hide Controls               
                this.dvDataContent.Visible = false;
                this.dvEmptyContent.Visible = false;

                // Search text             

                // Populate Items

                if (this.WeekEndDate != new DateTime(1100, 1, 1))
                {
                    List<ReturnWeeklySummaryViewBO> lstWeeklySummary = new List<ReturnWeeklySummaryViewBO>();


                    lstWeeklySummary = OrderDetailBO.GetWeekSummary(this.WeekEndDate, false);


                    if (lstWeeklySummary.Count > 0)
                    {
                        this.RadGridWeeklySummary.AllowPaging = (lstWeeklySummary.Count > this.RadGridWeeklySummary.PageSize);
                        this.RadGridWeeklySummary.DataSource = lstWeeklySummary;
                        this.RadGridWeeklySummary.DataBind();

                        Session["SummaryDetailsView"] = lstWeeklySummary;

                        this.dvDataContent.Visible = true;
                        //this.litGrandTotal.Text = total.ToString();
                    }
                    else
                    {
                        this.dvEmptyContent.Visible = true;
                    }


                    this.RadGridWeeklySummary.Visible = (lstWeeklySummary.Count > 0);
                }
            }
        }

        private void ReBindGrid()
        {
            if (Session["SummaryDetailsView"] != null)
            {
                RadGridWeeklySummary.DataSource = (List<ReturnWeeklySummaryViewBO>)Session["SummaryDetailsView"];
                RadGridWeeklySummary.DataBind();
            }
        }

        #endregion
    }
}