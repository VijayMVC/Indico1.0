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
using System.Web.UI.HtmlControls;

namespace Indico
{
    public partial class ViewCartons : IndicoPage
    {
        #region Fields

        private DateTime qpWeekEndDate = new DateTime(1100, 1, 1);

        #endregion

        #region Properties

        protected DateTime WeekEndDate
        {
            get
            {
                if (qpWeekEndDate != new DateTime(1100, 1, 1))
                    return qpWeekEndDate;
                qpWeekEndDate = DateTime.Now;
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
        //protected override void OnPreRender(EventArgs e)
        //{
        //    //Page Refresh
        //    Session["IsPostBack"] = Server.UrlEncode(Guid.NewGuid().ToString());
        //    ViewState["IsPostBack"] = Session["IsPostBack"];
        //}

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!this.IsPostBack)
            {
                PopulateControls();
            }
        }

        protected void rptShipmentOrders_OnItemBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;
            //total = 0;

            if (item.ItemIndex > -1 && item.DataItem is IGrouping<int, ReturnCartonsDetailsViewBO>)
            {
                List<ReturnCartonsDetailsViewBO> lstCartonrDetailsGroup = ((IGrouping<int, ReturnCartonsDetailsViewBO>)item.DataItem).ToList();

                if (lstCartonrDetailsGroup[0].ShipmentMode != null)
                {
                    Literal litComapny = (Literal)item.FindControl("litComapny");
                    litComapny.Text = lstCartonrDetailsGroup[0].CompanyName;

                    Literal litDate = (Literal)item.FindControl("litDate");
                    litDate.Text = WeekEndDate.ToString("dd MMMM yyyy");

                    Literal litAddress = (Literal)item.FindControl("litAddress");
                    litAddress.Text = lstCartonrDetailsGroup[0].Address;

                    Literal litSuberb = (Literal)item.FindControl("litSuberb");
                    litSuberb.Text = lstCartonrDetailsGroup[0].Suberb;

                    Literal litPostCode = (Literal)item.FindControl("litPostCode");
                    litPostCode.Text = lstCartonrDetailsGroup[0].State + " " + " , " + lstCartonrDetailsGroup[0].Country + lstCartonrDetailsGroup[0].PostCode;

                    //Literal litCountry = (Literal)item.FindControl("litCountry");
                    //litCountry.Text = lstCartonrDetailsGroup[0].Country;

                    //Literal litContectDetails = (Literal)item.FindControl("litContectDetails");
                    //litContectDetails.Text = lstOrderDetailsGroup[0].ContactDetails;

                    Repeater rptMode = (Repeater)item.FindControl("rptMode");
                    List<IGrouping<int, ReturnCartonsDetailsViewBO>> lstShipmentModeGroup = lstCartonrDetailsGroup.GroupBy(o => (int)o.ShimentModeID).ToList();

                    if (lstShipmentModeGroup.Count > 0)
                    {
                        rptMode.DataSource = lstShipmentModeGroup;
                        rptMode.DataBind();
                    }

                    //Literal litGrandTotal = (Literal)item.FindControl("litGrandTotal");
                    //litGrandTotal.Text = "Total" + " " + total.ToString();

                }

            }
        }

        protected void rptMode_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;

            if (item.ItemIndex > -1 && item.DataItem is IGrouping<int, ReturnCartonsDetailsViewBO>)
            {
                List<ReturnCartonsDetailsViewBO> lstmodes = ((IGrouping<int, ReturnCartonsDetailsViewBO>)item.DataItem).ToList();

                Literal litShipmentMode = (Literal)item.FindControl("litShipmentMode");
                litShipmentMode.Text = lstmodes[0].ShipmentMode;

                Repeater rptCarton = (Repeater)item.FindControl("rptCarton");

                if (lstmodes.Count > 0)
                {
                    rptCarton.DataSource = lstmodes.GroupBy(m => (int)m.Carton).ToList();
                    rptCarton.DataBind();
                }
            }
        }

        protected void rptCarton_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;

            if (item.ItemIndex > -1 && item.DataItem is IGrouping<int, ReturnCartonsDetailsViewBO>)
            {
                List<ReturnCartonsDetailsViewBO> lstCartonsGroup = ((IGrouping<int, ReturnCartonsDetailsViewBO>)item.DataItem).ToList();

                Literal litCartonNo = (Literal)item.FindControl("litCartonNo");
                litCartonNo.Text = lstCartonsGroup[0].Carton.ToString();

                Image imgCarton = (Image)item.FindControl("imgCarton");

                HtmlGenericControl divThumbnail = (HtmlGenericControl)item.FindControl("divThumbnail");

                Literal litTotal = (Literal)item.FindControl("litTotal");
                int count = 0;
                int qty = 0;

                WeeklyProductionCapacityBO objWeeklyProductionCapacity = new WeeklyProductionCapacityBO();
                objWeeklyProductionCapacity.WeekendDate = this.WeekEndDate;

                int id = objWeeklyProductionCapacity.SearchObjects().Select(o => o.ID).SingleOrDefault();

                //List<PackingListBO> lstPackingList = (new PackingListBO()).GetAllObject().Where(o => o.WeeklyProductionCapacity == id && o.CartonNo == lstCartonsGroup[0].CartonNo).ToList();

                // Fill Qty
                count = lstCartonsGroup.Sum(o => (int)o.FillQty);

                // Total Qty
                qty = lstCartonsGroup.Sum(o => (int)o.TotalQty);


                if (count == 0)
                {
                    imgCarton.ImageUrl = "~/Content/img/carton.png";
                    divThumbnail.Attributes.Add("style", "border:5px solid #C0C0C0;");
                }

                if (count > 0)
                {
                    imgCarton.ImageUrl = "~/Content/img/Half_Fill.png";
                    divThumbnail.Attributes.Add("style", "border:5px solid #0066FF;");
                }

                if (count == qty)
                {
                    imgCarton.ImageUrl = "~/Content/img/Close_Box.png";
                    divThumbnail.Attributes.Add("style", "border:5px solid #00FF00;");
                }

                litTotal.Text = count.ToString() + "/" + qty;
            }
        }

        protected void Timer_Tick(object sender, EventArgs e)
        {
            this.PopulateDataGrid();
            // this.updCartons.Update();
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
            List<ReturnCartonsDetailsViewBO> lstReturnCartonsDetailsView = new List<ReturnCartonsDetailsViewBO>();

            lstReturnCartonsDetailsView = PackingListBO.GetCartonsDetails(this.WeekEndDate);

            List<IGrouping<int, ReturnCartonsDetailsViewBO>> lstGroupReturnCartonsDetails = lstReturnCartonsDetailsView.GroupBy(m => (int)m.ShipTo).ToList();

            this.rptShipmentOrders.DataSource = lstGroupReturnCartonsDetails;
            this.rptShipmentOrders.DataBind();

        }

        #endregion
    }
}