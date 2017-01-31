using Dapper;
using Indico.Common;
using Indico.Models;
using Microsoft.ReportingServices.DataProcessing;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using Telerik.Web.UI;


namespace Indico
{
    public partial class Vendor : IndicoPage
    {
        private List<NameIdModel> Vendors { get { return (List<NameIdModel>)Session["Vendors"]; } set { Session["Vendors"] = value; } }
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                PopulateControls();
        }

        protected void VendorGrid_PageSizeChanged(object sender, Telerik.Web.UI.GridPageSizeChangedEventArgs e)
        {
            RebindGrid();
        }

        protected void VendorGrid_PageIndexChanged(object sender, Telerik.Web.UI.GridPageChangedEventArgs e)
        {
            RebindGrid();
        }

        protected void searchbutton_ServerClick(object sender, EventArgs e)
        {
            List<NameIdModel> vendor;
            using (var connection = GetIndicoConnnection())
            {
                vendor = connection.Query<NameIdModel>(String.Format("SELECT ID,Name FROM [dbo].[InvVendor] WHERE Name='{0}'",txtSearch.Value)).ToList();
                Vendors = vendor;
                RebindGrid();
            }


        }

        protected void VendorGrid_ItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                RebindGrid();
                
            }
        }


        protected void VendorGrid_SortCommand(object sender, GridCommandEventArgs e)
        {
            RebindGrid();
        }









        protected void VendorGrid_ItemDataBound(object sender, Telerik.Web.UI.GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;
                if (item.DataItem is NameIdModel && item.ItemIndex > -1)
                {
                    var model = item.DataItem as NameIdModel;

                    var linkDelete = (HyperLink)item.FindControl("linkDelete");
                    //linkDelete.Attributes.Add("qid", model.ID.ToString());

                    var linkEdit = (HyperLink)item.FindControl("linkEdit");
                    linkEdit.Attributes.Add("qid", model.ID.ToString());


                }
            }
        }

        protected void btnDelete_ServerClick(object sender, EventArgs e)
        {
            var selectedId = hdnSelectedItemID.Value;
            if (string.IsNullOrWhiteSpace(selectedId))
                return;
            using (var connection = GetIndicoConnnection())
            {
                var query = string.Format("DELETE [dbo].[InvVendor] WHERE [ID] = {0}", selectedId);
                connection.Execute(query);
            }
            Response.Redirect(Request.RawUrl);
        }

        protected void saveButtonServer_ServerClick(object sender, EventArgs e)
        {
            var selectedId = hdnSelectedItemID.Value;
            if (string.IsNullOrWhiteSpace(selectedId))
                return;
            using (var connection = GetIndicoConnnection())
            {
                var query = string.Format("UPDATE [dbo].[InvVendor] set Name='{0}' WHERE ID={1} ", txtName.Text, Convert.ToInt32(selectedId));

                connection.Execute(query);
            }
            Response.Redirect(Request.RawUrl);


        }


        protected void addButtonServer_ServerClick(object sender, EventArgs e)
        {
            var selectedId = hdnSelectedItemID.Value;
            if (string.IsNullOrWhiteSpace(selectedId))
                return;
            using (var connection = GetIndicoConnnection())
            {
                var query = string.Format("INSERT INTO InvVendor (Name) VALUES('{0}') ", txtName.Text);

                connection.Execute(query);
            }
            Response.Redirect(Request.RawUrl);



        }


        private void PopulateItemGrid()
        {
            List<NameIdModel> vendor;
            using (var connection = GetIndicoConnnection())
            {
                vendor = connection.Query<NameIdModel>("SELECT ID,Name FROM [dbo].[InvVendor]").ToList();
                Vendors = vendor;
                RebindGrid();
            }
        }
        private void RebindGrid()
        {
            VendorGrid.DataSource = Vendors;
            VendorGrid.DataBind();
        }

        private void PopulateControls()
        {

            litHeaderText.Text = ActivePage.Heading;
            PopulateItemGrid();


        }


        #region Web Methods

        [WebMethod]
        public static object GetItemData(int code)
        {
            if (code < 1)
                return null;
            using (var connection = GetIndicoConnnection())
            {
                var vendor = connection.Query<NameIdModel>("SELECT TOP 1 * FROM [dbo].[InvVendor] WHERE ID = " + code).FirstOrDefault();
                return new { vendor.ID, vendor.Name };
            }
        }

        #endregion




    }
}















