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
    public partial class InventoryCategory : IndicoPage
    {
        private List<NameIdModel> InventoryCategorys { get { return (List<NameIdModel>)Session["InventoryCategorys"];} set { Session["InventoryCategorys"] = value;}}
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                PopulateControls();
        }

        protected void CategoryGrid_PageSizeChanged(object sender, Telerik.Web.UI.GridPageSizeChangedEventArgs e)
        {
            RebindGrid();
        }

        protected void CategoryGrid_PageIndexChanged(object sender, Telerik.Web.UI.GridPageChangedEventArgs e)
        {
            RebindGrid();
        }

        protected void CategoryGrid_ItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                RebindGrid();
            }
        }


        protected void CategoryGrid_SortCommand(object sender, GridCommandEventArgs e)
        {
            RebindGrid();
        }

        protected void searchbutton_ServerClick(object sender, EventArgs e)
        {
            List<NameIdModel> category;
            using (var connection = GetIndicoConnnection())
            {
                category = connection.Query<NameIdModel>(String.Format("SELECT ID,Name FROM [dbo].[InvCategory] WHERE Name='{0}' and Parent is NULL", txtSearch.Value)).ToList();
                InventoryCategorys = category;
                RebindGrid();
            }


        }


        protected void CategoryGrid_ItemDataBound(object sender, Telerik.Web.UI.GridItemEventArgs e)
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
                var query = string.Format("DELETE [dbo].[InvCategory] WHERE [ID] = {0}", selectedId);
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
                var query = string.Format("UPDATE [dbo].[InvCategory] set Name='{0}' WHERE ID={1} ", txtName.Text, Convert.ToInt32(selectedId));

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
                var query = string.Format("INSERT INTO InvCategory (Name,Parent) VALUES('{0}',null) ", txtName.Text);

                connection.Execute(query);
            }
            Response.Redirect(Request.RawUrl);



        }

        private void PopulateItemGrid()
        {
            List<NameIdModel> inventoryCategory;
            using (var connection = GetIndicoConnnection())
            {
                inventoryCategory = connection.Query<NameIdModel>("SELECT ID,Name FROM [dbo].[InvCategory] WHERE Parent is null").ToList();
                InventoryCategorys = inventoryCategory;
                RebindGrid();
            }
        }
            private void RebindGrid()
        {
            CategoryGrid.DataSource = InventoryCategorys;
            CategoryGrid.DataBind();
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
                var category = connection.Query<NameIdModel>("SELECT TOP 1 * FROM [dbo].[InvCategory] WHERE ID = " + code).FirstOrDefault();
                return new {category.ID,category.Name};
            }
        }

        #endregion




    }
}
