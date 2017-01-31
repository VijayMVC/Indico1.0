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
using System.Windows.Media;
using System.Drawing;

namespace Indico
{
    public partial class StockView : IndicoPage
    {
        private List<StockModel> Stock { get { return (List<StockModel>)Session["Stock"]; } set { Session["Stock"] = value; } }
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                PopulateControls();
        }
        protected void StockGrid_PageSizeChanged(object sender, Telerik.Web.UI.GridPageSizeChangedEventArgs e)
        {
            RebindGrid();
        }

        protected void StockGrid_PageIndexChanged(object sender, Telerik.Web.UI.GridPageChangedEventArgs e)
        {
            RebindGrid();
        }

        protected void StockGrid_ItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                RebindGrid();
            }
        }


        protected void StockGrid_SortCommand(object sender, GridCommandEventArgs e)
        {
            RebindGrid();
        }

        protected void searchbutton_Click(object sender, EventArgs e)
        {
            List<StockModel> stock;

            int value;
            var st = txtSearch.Value;
            if (int.TryParse(st, out value) == false)
            {
                using (var connection = GetIndicoConnnection())
                {
                    stock = connection.Query<StockModel>(
                        string.Format(
                          @"SELECT * FROM [dbo].[ItemBalanceView] 
                        WHERE Name LIKE '%{0}%' OR Category LIKE '%{0}%' OR SubCategory LIKE '%{0}%'
                        OR Colour LIKE '%{0}%' OR Attribute LIKE'%{0}%' OR Uom LIKE '%{0}%' OR SupplierCode LIKE '%{0}%' 
                        OR Purchaser LIKE '%{0}%' OR Code LIKE '%{0}%'", st)).ToList();

                    Stock = stock;
                    RebindGrid();
                }
            }

            else
            {
                if (int.TryParse(st, out value) == true)
                {
                    using (var connection = GetIndicoConnnection())
                    {
                        stock = connection.Query<StockModel>(string.Format("SELECT * FROM [dbo].[ItemBalanceView] WHERE Id={0} OR MinLevel={0} OR Balance={0}", Convert.ToInt32(st))).ToList();

                        Stock = stock;
                        RebindGrid();
                    }
                }
            }

        }
        private void PopulateItemGrid()
        {
            List<StockModel> stock;
            using (var connection = GetIndicoConnnection())
            {
                stock = connection.Query<StockModel>("SELECT * from ItemBalanceView").ToList();
                Stock = stock;
                RebindGrid();
            }
        }

        private void RebindGrid()
        {
            StockGrid.DataSource = Stock;
            StockGrid.DataBind();
        }


        private void PopulateControls()
        {

            litHeaderText.Text = ActivePage.Heading;
            PopulateItemGrid();


        }

        protected void StockGrid_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (!(e.Item is GridDataItem))
                return;
            var item = e.Item as GridDataItem;
            if (!(item.DataItem is StockModel && item.ItemIndex > -1))
                return;
            var model = item.DataItem as StockModel;
            if (model.Balance < model.MinLevel)
            {
                //Color red = ColorTranslator.FromHtml("#ff1a1a");
                item.BackColor = System.Drawing.ColorTranslator.FromHtml("#ffcccc");

            }
            
        }
    }
}