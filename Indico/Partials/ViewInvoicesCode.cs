using System;
using System.Collections.Generic;
using Indico.Models;
using System.Data;
using Dapper;
using Telerik.Web.UI;
using System.Web.UI.WebControls;
using Indico.Common.Extensions;
using System.Linq;
using System.Web;

namespace Indico
{
    public partial class ViewInvoices
    {
        #region Fields

        #endregion

        #region Propeerties 

        private List<NewFactoryInvoiceViewModel> FactoryInvoices { get { return Session["FactoryInvoices"] as List<NewFactoryInvoiceViewModel>; } set { Session["FactoryInvoices"] = value; } }

        #endregion

        #region UI Event

        protected void OnInvoiceGridDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if ((item.ItemIndex > -1 && item.DataItem is NewFactoryInvoiceViewModel))
                {
                    var objInvoice = (NewFactoryInvoiceViewModel)item.DataItem;

                    var linkEdit = GetControl<HyperLink>(item, "linkEdit");
                    linkEdit.NavigateUrl = "/AddEditInvoice.aspx?id=" + objInvoice.Invoice.ToString();


                    var btnInvoiceDetail = GetControl<LinkButton>(item, "btnInvoiceDetail");
                    btnInvoiceDetail.Attributes.Add("qid", objInvoice.Invoice.ToString());

                    var btnInvoiceSummary = (LinkButton)item.FindControl("btnInvoiceSummary");
                    btnInvoiceSummary.Attributes.Add("qid", objInvoice.Invoice.ToString());

                    var btnCombineInvoice = (LinkButton)item.FindControl("btnCombineInvoice");
                    btnCombineInvoice.Attributes.Add("qid", objInvoice.Invoice.ToString());

                    var litStatus = (Literal)item.FindControl("litStatus");
                    litStatus.Text = "<span class=\"label label-" + objInvoice.Status.ToLower().Replace(" ", string.Empty).Trim() + "\">" + objInvoice.Status + "</span>";

                }
            }
        }

        protected void OnInvoiceGridItemCommand(object sender, GridCommandEventArgs e)
        {
            RebindInvoiceGrid();
        }

        protected void OnInvoiceGridPageIndexChanged(object sender, EventArgs e)
        {
            RebindInvoiceGrid();
        }

        protected void OnInvoiceGridGroupChanging(object sender, EventArgs e)
        {
            RebindInvoiceGrid();
        }

        protected void OnInvoiceGridSortCommand(object sender, EventArgs e)
        {
            RebindInvoiceGrid();
        }

        protected void OnInvoiceGridHeaderContextMenuItemClick(object sender, EventArgs e)
        {
            RebindInvoiceGrid();
        }

        protected void OnSearchButtonClick(object sender, EventArgs e)
        {
            using (var connection = GetIndicoConnnection())
            {
                LoadFactoryInvoiceDateGrid(connection, SearchTextBox.Text);
            }
        }

        #endregion

        #region Peivate function

        private void PopulateDataGrid()
        {
            if (SearchTextBox.Text == null || SearchTextBox.Text == "")
            {
                using (var connection = GetIndicoConnnection())
                {
                    LoadFactoryInvoiceDateGrid(connection);
                }
            }
            else
            {
                using (var connection = GetIndicoConnnection())
                {
                    LoadFactoryInvoiceDateGrid(connection, SearchTextBox.Text);
                }
            }
        }

        private void LoadFactoryInvoiceDateGrid(IDbConnection connection, string key = null)
        {
            dvEmptyContent.Visible = false;
            dvNoSearchResult.Visible = false;

            var query = string.Format(@"SELECT 
	                                   inv.ID AS Invoice
	                                  ,[InvoiceNo]
                                      ,[InvoiceDate]      
	                                  ,[ShipmentDate] AS ETD
                                      ,dca.[Address] AS ShipTo
	                                  ,spm.Name AS ShipmentMode
                                      ,[AWBNo]
	                                  ,dca.[Address] AS BillTo
	                                  ,ins.Name AS [Status] 
	                                  ,COUNT(iodi.ID) AS Qty
	                                  ,SUM(iodi.FactoryPrice) AS FactoryTotal
                                        FROM [dbo].[Invoice] inv
                                            INNER JOIN [dbo].[ShipmentMode] spm
		                                        ON spm.[ID] = inv.ShipmentMode
	                                        INNER JOIN [dbo].[DistributorClientAddress] dca
		                                        ON dca.[ID] = inv.ShipTo
	                                        INNER JOIN [dbo].[InvoiceOrderDetailItem] iodi
		                                        ON inv.ID = iodi.Invoice
                                            INNER JOIN [dbo].[InvoiceStatus] ins
                                                ON ins.ID = inv.[Status]
                                        WHERE [InvoiceNo] IS NOT NULL AND [IndimanInvoiceNo] IS NULL {0}
	                                    AND iodi.IsRemoved = 0
                                        GROUP BY inv.ID, inv.InvoiceNo ,[InvoiceDate],[ShipmentDate],dca.[Address],spm.Name,[AWBNo],dca.[Address],ins.[Name]",
                string.IsNullOrWhiteSpace(key) ? "" :
                string.Format(@"AND (dca.[Address] LIKE '%{0}%' OR [InvoiceNo] LIKE '%{0}%' OR [AWBNo] LIKE '%{0}%')", key));

            var factoryInvoices = connection.Query<NewFactoryInvoiceViewModel>(query).ToList();

            foreach (NewFactoryInvoiceViewModel n in factoryInvoices)
                FactoryInvoices = factoryInvoices;
            RebindInvoiceGrid();
            InvoiceGrid.Visible = (factoryInvoices.Count > 0);
        }

        private void RebindInvoiceGrid()
        {
            BindData(InvoiceGrid, FactoryInvoices);
        }
        #endregion
    }
}