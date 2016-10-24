using Dapper;
using Indico.BusinessObjects;
using Indico.Common;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;

namespace Indico
{
    public partial class CloneOrder : IndicoPage
    {
        #region Fields

        private int urlQueryID = -1;

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

        #endregion

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                if (this.QueryID > 0)
                {
                    OrderBO objOrder = new OrderBO();
                    objOrder.ID = this.QueryID;
                    objOrder.GetObject();

                    OrderDetailBO objOrderDetail = new OrderDetailBO();
                    objOrderDetail.Order = objOrder.ID;
                    List<OrderDetailBO> lstOrderDetails = objOrderDetail.SearchObjects();
                    objOrderDetail = lstOrderDetails.First();

                    this.lblDistributor.Text = objOrder.objDistributor.Name;
                    this.lblJobName.Text = objOrder.objClient.Name;
                    this.lblClient.Text = objOrder.objClient.objClient.Name;
                    this.lblDespatchAddress.Text = objOrder.objDespatchToAddress.CompanyName + "  " + objOrder.objDespatchToAddress.Address + "  "
                                                    + objOrder.objDespatchToAddress.PostCode + "  " + objOrder.objDespatchToAddress.Suburb + "  "
                                                    + objOrder.objDespatchToAddress.PostCode + "  " + objOrder.objDespatchToAddress.State + "  "
                                                    + objOrder.objDespatchToAddress.objCountry.ShortName; ;

                    this.lblBillingAddress.Text = objOrder.objBillingAddress.CompanyName + "  " + objOrder.objBillingAddress.Address + "  "
                                                    + objOrder.objBillingAddress.PostCode + "  " + objOrder.objBillingAddress.Suburb + "  "
                                                    + objOrder.objBillingAddress.PostCode + "  " + objOrder.objBillingAddress.State + "  "
                                                    + objOrder.objBillingAddress.objCountry.ShortName;
                    int processingPeriod = 5;
                    int.TryParse(IndicoPage.GetSetting("OPP"), out processingPeriod);
                    lblDateRequiredinCustomersHand.Text = IndicoPage.GetNextWeekday(DayOfWeek.Monday).AddDays(7 * (processingPeriod - 1)).ToString("dd MMMM yyyy");


                    int.TryParse(IndicoPage.GetSetting("OPP"), out processingPeriod);
                    lblShipmentDate.Text = IndicoPage.GetNextWeekday(DayOfWeek.Monday).AddDays(7 * (processingPeriod - 1) - 2).ToString("dd MMMM yyyy");

                    this.lblShipmentTerm.Text = objOrderDetail.objPaymentMethod.Name;
                    this.lblShipmentMode.Text = objOrderDetail.objShipmentMode.Name;

                    this.rptOrderDetails.DataSource = lstOrderDetails;
                    this.rptOrderDetails.DataBind();
                }
            }
        }
        protected void rptOrderDetails_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is OrderDetailBO)
            {
                OrderDetailBO objOrderDetail = (OrderDetailBO)item.DataItem;

                CheckBox chkOrderDetail = (CheckBox)item.FindControl("chkOrderDetail");
                Label lblVisualLayout = (Label)item.FindControl("lblVisualLayout");
                lblVisualLayout.Text = objOrderDetail.objVisualLayout.NamePrefix;
                HtmlAnchor ancVLImage = (HtmlAnchor)item.FindControl("ancVLImage");
                HtmlGenericControl ivlimageView = (HtmlGenericControl)item.FindControl("ivlimageView");

                if (!string.IsNullOrEmpty(ancVLImage.HRef))
                {
                    ancVLImage.Attributes.Add("class", "btn-link preview");
                    ivlimageView.Attributes.Add("class", "icon-eye-open");

                    List<float> lstVLImageDimensions = (new ImageProcess()).GetResizedImageDimension(960, 720, 420, 360);
                    if (lstVLImageDimensions.Count > 0)
                    {
                        ancVLImage.Attributes.Add("height", lstVLImageDimensions[0].ToString());
                        ancVLImage.Attributes.Add("width", lstVLImageDimensions[1].ToString());
                    }
                }
                else
                {
                    ancVLImage.Title = "Visual Layout Image Not Available";
                    ivlimageView.Attributes.Add("class", "icon-eye-close");
                }

                HiddenField ODID = (HiddenField)item.FindControl("hdnODID");
                ODID.Value = objOrderDetail.ID.ToString();
            }
        }

        protected void btnSaveChanges_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                try
                {
                    string orderDetailIDs = string.Empty;

                    foreach (RepeaterItem item in rptOrderDetails.Items)
                    {
                        CheckBox chkOrderDetail = (CheckBox)item.FindControl("chkOrderDetail");
                        HiddenField ODID = (HiddenField)item.FindControl("hdnODID");

                        if (chkOrderDetail.Checked)
                            orderDetailIDs += ODID.Value + ",";
                    }

                    int success = 0;

                    System.Data.SqlClient.SqlConnection connection = new System.Data.SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString);
                    connection.Open();

                    int orderID = this.QueryID;

                    string query = string.Format(@"EXEC [Indico].[dbo].[SPC_CloneOrder] '{0}','{1}','{2}'",
                                                                                         this.LoggedUser.ID, orderID, orderDetailIDs);
                    var result = connection.Query<int>(query);
                    connection.Close();

                    success = result.First();

                    // Response.Redirect("/ViewOrders.aspx");

                }
                catch (Exception ex)
                {

                }
            }
        }

        protected void btnClose_ServerClick(object sender, EventArgs e)
        {
            Response.Redirect("/ViewOrders.aspx");
        }

        protected void cvOrderDetails_ServerValidate(object source, ServerValidateEventArgs args)
        {
            args.IsValid = false;

            foreach (RepeaterItem item in rptOrderDetails.Items)
            {
                CheckBox chkOrderDetail = (CheckBox)item.FindControl("chkOrderDetail");

                if (chkOrderDetail.Checked)
                {
                    args.IsValid = true;
                    break;
                }
            }
        }
    }
}