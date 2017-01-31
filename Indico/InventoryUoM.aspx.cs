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
    public partial class InventoryUoM : IndicoPage
    {
        private List<NameIdModel> InventoryUoMs { get { return (List<NameIdModel>)Session["InventoryUoMs"]; } set { Session["InventoryUoMs"] = value; } }
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                PopulateControls();
        }

        protected void UoMGrid_PageSizeChanged(object sender, Telerik.Web.UI.GridPageSizeChangedEventArgs e)
        {
            RebindGrid();
        }

        protected void UoMGrid_PageIndexChanged(object sender, Telerik.Web.UI.GridPageChangedEventArgs e)
        {
            RebindGrid();
        }

        protected void UoMGrid_ItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                RebindGrid();
            }
        }


        protected void UoMGrid_SortCommand(object sender, GridCommandEventArgs e)
        {
            RebindGrid();
        }







        protected void searchbutton_ServerClick(object sender, EventArgs e)
        {
            List<NameIdModel> uom;
            using (var connection = GetIndicoConnnection())
            {
                uom = connection.Query<NameIdModel>(String.Format("SELECT ID,Name FROM [dbo].[Unit] WHERE Name='{0}'", txtSearch.Value)).ToList();
                InventoryUoMs = uom;
                RebindGrid();
            }


        }

        protected void UoMGrid_ItemDataBound(object sender, Telerik.Web.UI.GridItemEventArgs e)
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
                var query = string.Format("DELETE [dbo].[Unit] WHERE [ID] = {0}", selectedId);
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
                var query = string.Format("UPDATE [dbo].[Unit] set Name='{0}' WHERE ID={1} ", txtName.Text, Convert.ToInt32(selectedId));

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
                var query = string.Format("INSERT INTO [dbo].[Unit] (Name) VALUES('{0}') ", txtName.Text);

                connection.Execute(query);
            }
            Response.Redirect(Request.RawUrl);



        }

        private void PopulateItemGrid()
        {
            List<NameIdModel> inventoryUoM;
            using (var connection = GetIndicoConnnection())
            {
                inventoryUoM = connection.Query<NameIdModel>("SELECT ID,Name FROM [dbo].[Unit]").ToList();
                InventoryUoMs = inventoryUoM;
                RebindGrid();
            }
        }

        private void RebindGrid()
        {
            UoMGrid.DataSource = InventoryUoMs;
            UoMGrid.DataBind();
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
                var UoM = connection.Query<NameIdModel>("SELECT TOP 1 * FROM [dbo].[Unit] WHERE ID = " + code).FirstOrDefault();
                return new { UoM.ID, UoM.Name };
            }
        }

        #endregion




    }
}



















