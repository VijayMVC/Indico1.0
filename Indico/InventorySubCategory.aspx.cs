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
    public partial class InventorySubCategory : IndicoPage
    {
        private List<InventorySubCategoryModel> InventorySubCategorys { get { return (List<InventorySubCategoryModel>)Session["InventorySubCategorys"]; } set { Session["InventorySubCategorys"] = value; } }
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                PopulateControls();
        }

        protected void SubCategoryGrid_PageSizeChanged(object sender, Telerik.Web.UI.GridPageSizeChangedEventArgs e)
        {
            RebindGrid();
        }

        protected void SubCategoryGrid_PageIndexChanged(object sender, Telerik.Web.UI.GridPageChangedEventArgs e)
        {
            RebindGrid();
        }

        protected void SubCategoryGrid_ItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                RebindGrid();
            }
        }


        protected void SubCategoryGrid_SortCommand(object sender, GridCommandEventArgs e)
        {
            RebindGrid();
        }





        protected void SubCategoryGrid_ItemDataBound(object sender, Telerik.Web.UI.GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;
                if (item.DataItem is InventorySubCategoryModel && item.ItemIndex > -1)
                {
                    var model = item.DataItem as InventorySubCategoryModel;

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
                var query = string.Format("DELETE [dbo].[InvSubCategory] WHERE [ID] = {0}", selectedId);
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
                var query = string.Format("INSERT INTO InvCategory (Name,Parent) VALUES('{0}',{1}) ", txtName.Text,ddCategory.SelectedValue);

                connection.Execute(query);
            }
            Response.Redirect(Request.RawUrl);



        }

        protected void searchbutton_ServerClick(object sender, EventArgs e)
        {
            List<InventorySubCategoryModel> category;
            using (var connection = GetIndicoConnnection())
            {
                category = connection.Query<InventorySubCategoryModel>(String.Format("SELECT sc.ID,sc.Name,c.Name AS CategoryName FROM [dbo].[InvCategory] sc  INNER JOIN [dbo].[InvCategory] c ON sc.Parent = c.ID WHERE c.Name='{0}' OR sc.Name='{1}'",txtSearch.Value,txtSearch.Value)).ToList();
                InventorySubCategorys = category;
                RebindGrid();
            }


        }


        private void PopulateItemGrid()
        {
            List<InventorySubCategoryModel> inventorySubCategory;
            using (var connection = GetIndicoConnnection())
            {
                inventorySubCategory = connection.Query<InventorySubCategoryModel>("SELECT sc.ID,sc.Name,c.Name AS CategoryName FROM [dbo].[InvCategory] sc  INNER JOIN [dbo].[InvCategory] c ON sc.Parent = c.ID").ToList();
                InventorySubCategorys = inventorySubCategory;
                RebindGrid();
            }
        }

        private void RebindGrid()
        {
            SubCategoryGrid.DataSource = InventorySubCategorys;
            SubCategoryGrid.DataBind();
        }

        private void PopulateControls()
        {

            litHeaderText.Text = ActivePage.Heading;
            PopulateItemGrid();

            var cat = new InventorySubCategoryModel { Name = "Please select", ID = 0 };
            var cats = new List<InventorySubCategoryModel> { cat };
            cats.AddRange(GetCategory());
            ddCategory.DataSource = cats;
            ddCategory.DataBind();
        }

        #region Web Methods

        [WebMethod]
        public static object GetItemData(int code)
        {
            if (code < 1)
                return null;
            using (var connection = GetIndicoConnnection())
            {
                var subcategory = connection.Query<InventorySubCategoryModel>("SELECT TOP 1 * FROM [dbo].[InvCategory] WHERE ID = " + code).FirstOrDefault();
                return new { subcategory.ID, subcategory.Name };
            }
        }

        [WebMethod]
        public static List<InventorySubCategoryModel> GetCategory()
        {

            using (var connection = GetIndicoConnnection())
            {
                return connection.Query<InventorySubCategoryModel>("SELECT ID,Name FROM [dbo].[InvCategory] WHERE Parent is NULL ").ToList();
            }
        }











        #endregion












    }
    }


































































