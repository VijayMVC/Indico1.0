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
    public partial class Receipts :IndicoPage
    {
        private List<ReceiptsModel> Receipt { get { return (List<ReceiptsModel>)Session["Receipt"]; } set { Session["Receipt"] = value; } }
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                PopulateControls();
        }


        protected void ReceiptsGrid_PageSizeChanged(object sender, Telerik.Web.UI.GridPageSizeChangedEventArgs e)
        {
            RebindGrid();
        }

        protected void ReceiptsGrid_PageIndexChanged(object sender, Telerik.Web.UI.GridPageChangedEventArgs e)
        {
            RebindGrid();
        }


        protected void ReceiptsGrid_ItemDataBound(object sender, Telerik.Web.UI.GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;
                if (item.DataItem is ReceiptsModel && item.ItemIndex > -1)
                {
                    var model = item.DataItem as ReceiptsModel;

                    var linkDelete = (HyperLink)item.FindControl("linkDelete");
                    linkDelete.Attributes.Add("qid", model.ID.ToString());

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
                var query = string.Format("DELETE [dbo].[SPTran] WHERE [ID] = {0}", selectedId);
                connection.Execute(query);
            }
            Response.Redirect(Request.RawUrl);

        }
        protected void btnSaveChanges_ServerClick(object sender, EventArgs e)
        {
            var selectedId = hdnSelectedItemID.Value;
            using (var connection = GetIndicoConnnection())
            {
                DateTime date;
                if (!DateTime.TryParse(txtDate.Text, out date))
                    date = DateTime.ParseExact(txtDate.Text, "MM/dd/yyyy", null);
                var query = string.Format("UPDATE SPtran SET Tranno='{0}',TranDate='{1}',Item={2},Qty={3},Modifier={4},ModifierDate='{5}' WHERE ID={6}", TransactionNo.Text, date.ToString("yyyyMMdd"), ddlItem.SelectedValue, Convert.ToInt32(txtQty.Text), Convert.ToInt32(LoggedUser.ID), DateTime.Now.ToString("yyyyMMdd"), selectedId);
                connection.Execute(query);
            }
            Response.Redirect(Request.RawUrl);


        }
        protected void searchbutton_Click(object sender, EventArgs e)
        {
            int value;
            string st = txtSearch.Value;
            List<ReceiptsModel> receipt;
            if (int.TryParse(st, out value) == false)
            {

                using (var connection = GetIndicoConnnection())
                {
                    receipt = connection.Query<ReceiptsModel>(String.Format("SELECT * FROM [dbo].[ReceiptsView] WHERE TransactionNo='{0}' OR ItemName='{1}'", st, st)).ToList();

                    receipt.ForEach(c => c.setdate());
                    Receipt = receipt;
                    RebindGrid();
                }



            }


            else
            {
                if (int.TryParse(st, out value) ==true)
                {
                    using (var connection = GetIndicoConnnection())
                    {
                        receipt = connection.Query<ReceiptsModel>(String.Format("SELECT * FROM [dbo].[ReceiptsView] WHERE Quantity={0}",Convert.ToInt32(st))).ToList();

                        receipt.ForEach(c => c.setdate());
                        Receipt = receipt;
                        RebindGrid();
                    }

                }







            }
            }

        protected void addButton_ServerClick(object sender, EventArgs e)
        {
            var selectedId = hdnSelectedItemID.Value;
            using (var connection = GetIndicoConnnection())
            {
                
                var query = string.Format("INSERT INTO [dbo].SPTran (Type,Tranno,TranDate,Item,Qty,Creator,CreatedDate) VALUES({0},'{1}','{2}',{3},{4},{5},'{6}')", 1, TransactionNo.Text, DateTime.Parse(txtDate.Text).ToString("yyyyMMdd"), ddlItem.SelectedValue, Convert.ToInt32(txtQty.Text), Convert.ToInt32(LoggedUser.ID), DateTime.Now.ToString("yyyyMMdd"));
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

        private void PopulateControls()
        {
            litHeaderText.Text = ActivePage.Heading;
            PopulateItemGrid();
            var cat = new NameIdModel { Name = "Please select", ID = 0 };
            var cats = new List<NameIdModel> { cat };
            cats.AddRange(GetItems());
            ddlItem.DataSource = cats;
            ddlItem.DataBind();

        }


        private void PopulateItemGrid()
        {
            List<ReceiptsModel> receipt;
            using (var connection = GetIndicoConnnection())
            {
                receipt = connection.Query<ReceiptsModel>("SELECT * FROM [dbo].[ReceiptsView]").ToList();
               // receipt.ForEach(c => c.setdate());
                Receipt = receipt;
                RebindGrid();
            }
        }

        private void RebindGrid()
        {
            ReceiptsGrid.DataSource = Receipt;
            ReceiptsGrid.DataBind();
        }

        protected void ReceiptsGrid_ItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                RebindGrid();
            }
        }


        protected void ReceiptsGrid_SortCommand(object sender, GridCommandEventArgs e)
        {
            RebindGrid();
        }

        [WebMethod]
        public static List<NameIdModel> GetItems()
        {
            using (var connection = GetIndicoConnnection())
            {
                return connection.Query<NameIdModel>("SELECT Id as Id,Name FROM [dbo].[InvItem]").ToList();
            }
        }

        [WebMethod]
        public static object GetItemData(int code)
        {
            if (code < 1)
                return null;
            using (var connection = GetIndicoConnnection())
            {
                var item = connection.Query<ReceiptsModel>("SELECT TOP 1 * FROM [dbo].[ReceiptsView] WHERE ID = " + code).FirstOrDefault();
                return new { item.TransactionNo, Date = item.Date.ToString(),item.Item, item.Quantity };
            }
        }

    }
}