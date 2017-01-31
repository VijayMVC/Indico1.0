using ClosedXML.Excel;
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
    public partial class InventoryItem : IndicoPage
    {

        private List<InvItemModel> InventoryItems { get { return (List<InvItemModel>)Session["InventoryItems"]; } set { Session["InventoryItems"] = value; } }

        #region Events

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                PopulateControls();
        }

        protected void ItemGrid_PageSizeChanged(object sender, Telerik.Web.UI.GridPageSizeChangedEventArgs e)
        {
            RebindGrid();
        }

        protected void ItemGrid_PageIndexChanged(object sender, Telerik.Web.UI.GridPageChangedEventArgs e)
        {
            RebindGrid();
        }

        protected void ItemGrid_ItemDataBound(object sender, Telerik.Web.UI.GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;
                if(item.DataItem is InvItemModel && item.ItemIndex>-1)
                {
                    var model = item.DataItem as InvItemModel;

                   
                    

                    var linkEdit = (HyperLink)item.FindControl("linkEdit");
                    linkEdit.Attributes.Add("qid", model.Id.ToString());


                }
            }
        }
        protected void searchbutton_ServerClick(object sender, EventArgs e)
        {
            List<InvItemModel> inventoryItems;

            string st = txtSearch.Value;
            int value;
            if (int.TryParse(st, out value))
            {
                using (var connection = GetIndicoConnnection())
                {
                    inventoryItems = connection.Query<InvItemModel>(String.Format("SELECT * FROM [dbo].[GetInventoryItemsView] WHERE MinLevel={0} OR Code='{1}'",Convert.ToInt32(st),st)).ToList();
                    InventoryItems = inventoryItems;
                    RebindGrid();
                }
            }

            else
            {

                using (var connection = GetIndicoConnnection())
                {
                    inventoryItems = connection.Query<InvItemModel>(String.Format("SELECT * FROM [dbo].[GetInventoryItemsView] WHERE Name='{0}' OR Category='{1}' OR SubCategory='{2}' OR Colour='{3}' OR Attribute='{4}' OR Uom='{5}' OR SupplierCode='{6}' OR Purchaser='{7}' OR Code='{8}'",st,st,st,st,st,st,st,st,st)).ToList();
                    InventoryItems = inventoryItems;
                    RebindGrid();
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
                var query = string.Format("DELETE [dbo].[InvItem] WHERE [Id] = {0}", selectedId);
                connection.Execute(query);
            }
            Response.Redirect(Request.RawUrl);
        }
        protected void btnSaveChanges_ServerClick(object sender, EventArgs e)
        {



            var selectedId = hdnSelectedItemID.Value;
            var category = Convert.ToInt32(ddlCategory.SelectedValue);
            var subcategory = Convert.ToInt32(ddlSubCat.SelectedValue);
            var uom = Convert.ToString(Uom.SelectedValue);
            var suppliercode = Convert.ToString(ddlSuplierCode.SelectedValue);
            var purchaserid = Convert.ToString(ddlPurchaser.SelectedValue);

            if (string.IsNullOrWhiteSpace(selectedId))
                return;
            using (var connection = GetIndicoConnnection())
            {
                var query = string.Format("UPDATE [dbo].[InvItem] set Name='{0}',Category={1},SubCategory={2},Colour='{3}',Attribute='{4}',MinLevel={5},Uom={6},Supplier={7},Purchaser={8},Code='{9}' WHERE Id={10} ", txtName.Text, category, subcategory, txtColor.Text, txtAttribute.Text, Convert.ToInt32(txtMinLevel.Text), uom, suppliercode, purchaserid,txtCode.Text,Convert.ToInt32(selectedId));

                connection.Execute(query);
            }
            Response.Redirect(Request.RawUrl);

        }


        protected void addButton_ServerClick(object sender, EventArgs e)
        {
            var selectedId = hdnSelectedItemID.Value;
            var category = Convert.ToInt32(ddlCategory.SelectedValue);
            var subcategory = Convert.ToInt32(ddlSubCat.SelectedValue);
            var uom = Convert.ToString(Uom.SelectedValue);
            var suppliercode = Convert.ToString(ddlSuplierCode.SelectedValue);
            var purchaserid = Convert.ToString(ddlPurchaser.SelectedValue);


            if (string.IsNullOrWhiteSpace(selectedId))
                return;
            using (var connection = GetIndicoConnnection())
            {
                var query = string.Format("INSERT INTO [dbo].[InvItem](Name,Category,SubCategory,Colour,Attribute,MinLevel,Uom,Supplier,Purchaser,Status,Code) values('{0}',{1},{2},'{3}','{4}',{5},{6},{7},{8},{9},'{10}')",txtName.Text,category,subcategory,txtColor.Text,txtAttribute.Text,Convert.ToInt32(txtMinLevel.Text),uom,suppliercode,purchaserid,1,txtCode.Text);
                connection.Execute(query);
            }
            Response.Redirect(Request.RawUrl);
            }

        protected void cvTxtName_ServerValidate(object source, ServerValidateEventArgs args)
        {

        }

        
        protected void btnAddNew_ServerClick(object sender, EventArgs e)
        {
        }

        #endregion

        #region Private Methods

        private void PopulateControls()
        {
            litHeaderText.Text = ActivePage.Heading;
            PopulateItemGrid();

            var cat = new NameIdModel { Name = "Please select", ID = 0 };
            var cats = new List<NameIdModel> { cat };
            cats.AddRange(GetCategories());
            ddlCategory.DataSource = cats;
            ddlCategory.DataBind();


            cat = new NameIdModel { Name = "Please select", ID = 0 };
             cats = new List<NameIdModel> { cat };
            cats.AddRange(GetUom());
            Uom.DataSource = cats;
            Uom.DataBind();

            cat = new NameIdModel { Name = "Please select", ID = 0 };
             cats = new List<NameIdModel> { cat };
            cats.AddRange(GetSupplier());
            ddlSuplierCode.DataSource = cats;
            ddlSuplierCode.DataBind();

            cat = new NameIdModel { Name = "Please select", ID = 0 };
             cats = new List<NameIdModel> { cat };
            cats.AddRange(GetPurchaser());
            ddlPurchaser.DataSource = cats;
            ddlPurchaser.DataBind();
        }

        private void PopulateItemGrid()
        {
            List<InvItemModel> inventoryItems;
            using (var connection = GetIndicoConnnection())
            {
                inventoryItems = connection.Query<InvItemModel>("SELECT * FROM [dbo].[GetInventoryItemsView]").ToList();
                inventoryItems.ForEach(c => c.SetStatus());
                InventoryItems = inventoryItems;
                RebindGrid();
            }
        }

        private void RebindGrid()
        {
            ItemGrid.DataSource = InventoryItems;
            ItemGrid.DataBind();
        }

        #endregion

        #region Web Methods

        [WebMethod]
        public static  object GetItemData(int code)
        {
            if (code < 1)
                return null;
            using (var connection = GetIndicoConnnection())
            {
                var item = connection.Query<InvItemModel>("SELECT TOP 1 * FROM [dbo].[GetInventoryItemsView] WHERE Id = " + code).FirstOrDefault();
                return new { item.Code,item.Name,item.Attribute, Category = item.CategoryID,item.Id,item.Colour,item.MinLevel, Purchaser = item.PurchaserID, SubCategory = item.SubCategoryID, SupplierCode = item.SupplierCodeID,Uom = item.UomID};
            }
        }

        [WebMethod]
        public static List<NameIdModel> GetCategories(int parent = 0)
        {
            using (var connection = GetIndicoConnnection())
            {
                return connection.Query<NameIdModel>(string.Format("SELECT Name,ID FROM [dbo].[InvCategory] {0}", parent < 1 ? "WHERE Parent IS NULL " : "WHERE Parent = " + parent)).ToList();
            }
        }
        [WebMethod]
        public static List<NameIdModel> GetUom()
        {

            using (var connection = GetIndicoConnnection())
            {
                return connection.Query<NameIdModel>("SELECT ID,Name FROM [dbo].[Unit]").ToList();
            }
        }

        [WebMethod]
        public static List<NameIdModel> GetSupplier()
        {

            using (var connection = GetIndicoConnnection())
            {
                return connection.Query<NameIdModel>("SELECT ID,Name FROM [dbo].[Supplier]").ToList();
            }
        }



        [WebMethod]

        public static List<NameIdModel> GetPurchaser()
        {


            using (var connection = GetIndicoConnnection())
            {
                return connection.Query<NameIdModel>("SELECT ID,Name FROM [dbo].[InvPurchaser]").ToList();
            }
        }

        #endregion

        protected void ddlCategory_SelectedIndexChanged(object sender, EventArgs e)
        {
            var id = Convert.ToInt32(ddlCategory.SelectedValue);
            ddlSubCat.Items.Clear();
            ddlSubCat.DataSource = id < 1 ? new List<NameIdModel>() : GetCategories(id);
            ddlSubCat.DataBind();
        }

        protected void ItemGrid_ItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                RebindGrid();
            }
        }


        protected void ItemGrid_SortCommand(object sender, GridCommandEventArgs e)
        {
            RebindGrid();
        }

        




    }
}