using System;
using System.Collections.Generic;
using Indico.Models;
using System.Data;
using Dapper;
using Telerik.Web.UI;
using System.Web.UI.WebControls;
using System.Linq;


namespace Indico
{
    public partial class ViewInvoices
    {
        #region Fields

        #endregion

        #region Properties 

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
                    linkEdit.NavigateUrl = "/AddEditInvoice.aspx?id=" + objInvoice.Invoice.ToString() + "&Type=f";

                    var linkCreIndiInvoice = GetControl<HyperLink>(item, "linkCreIndiInvoice");
                    linkCreIndiInvoice.NavigateUrl = "/AddEditInvoice.aspx?id=" + objInvoice.Invoice.ToString() + "&Type=i";

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
            SearchTextBox.Visible = true;

            var query = string.Format(@"IF OBJECT_ID('tempdb..#QtyInfo') IS NOT NULL DROP TABLE #QtyInfo
	                                SELECT inv.ID AS InvoiceOrderDetailItemID,
			                                SUM(odq.Qty) AS Qty INTO #QtyInfo
	                                FROM [dbo].[Invoice] invoice
	                                    INNER JOIN  [dbo].[InvoiceOrderDetailItem] inv
			                                ON invoice.ID = inv.Invoice
		                                INNER JOIN [Indico].[dbo].[OrderDetail] od
			                                ON inv.OrderDetail = od.ID
		                                INNER JOIN [Indico].[dbo].[OrderDetailQty] odq
			                                ON odq.OrderDetail = od.ID
	                                GROUP BY inv.ID
                                SELECT 
			                                 invoice.ID AS Invoice
	                                        ,invoice.[InvoiceNo]
                                            ,invoice.[InvoiceDate]
                                            ,invoice.[IndimanInvoiceNo]
                                            ,invoice.[IndimanInvoiceDate]
	                                        ,invoice.[ShipmentDate] AS ETD
			                                ,sm.Name AS ShipmentMode
			                                ,CONCAT(dca.[CompanyName],dca.[Address],dca.[Suburb],dca.[State],dca.PostCode,cu.ShortName) AS ShipTo
			                                ,invoice.AWBNo
			                                ,CONCAT(dcab.[CompanyName],dcab.[Address],dcab.[Suburb],dcab.[State],dcab.PostCode,cub.ShortName) AS BillTo
			                                ,ins.Name AS [Status] 
			                                ,SUM(qi.Qty) AS Qty
			                                ,SUM(qi.Qty * (inv.FactoryPrice + inv.OtherCharges)) AS FactoryTotal
	                                FROM [dbo].[Invoice] invoice
	                                    INNER JOIN  [dbo].[InvoiceOrderDetailItem] inv
			                                ON invoice.ID = inv.Invoice
		                                INNER JOIN [Indico].[dbo].[ShipmentMode] sm
			                                ON invoice.ShipmentMode = sm.[ID]
		                                INNER JOIN [dbo].[DistributorClientAddress] dca
		                                    ON invoice.ShipTo = dca.[ID]
										INNER JOIN [dbo].[Country] cu
											ON dca.Country = cu.ID
										INNER JOIN [dbo].[DistributorClientAddress] dcab
											ON invoice.BillTo = dcab.[ID]
										INNER JOIN [dbo].[Country] cub
											ON dcab.Country = cub.ID
		                                INNER JOIN [dbo].[InvoiceStatus] ins
                                            ON invoice.[Status] = ins.ID 
		                                INNER JOIN #QtyInfo qi
			                                ON inv.ID = qi.InvoiceOrderDetailItemID		
		                                INNER JOIN [Indico].[dbo].[OrderDetail] od
			                                ON inv.OrderDetail = od.ID
		                                INNER JOIN [Indico].[dbo].[Order] o
			                                ON od.[Order] = o.ID
		                                INNER JOIN [Indico].[dbo].[OrderStatus] os
			                                ON o.[Status] = os.ID		
	                                WHERE ([InvoiceNo] <> '' OR [InvoiceNo] <> NULL)  AND ([IndimanInvoiceNo] IS NULL OR [IndimanInvoiceNo] = '' ) {0}
	                                AND inv.IsRemoved = 0
	                                GROUP BY invoice.ID, invoice.[InvoiceNo]
                                              ,invoice.[InvoiceDate]
                                              ,invoice.[IndimanInvoiceNo]
                                              ,invoice.[IndimanInvoiceDate]
	                                          ,invoice.[ShipmentDate]
			                                  ,invoice.[ModifiedDate]
			                                  ,sm.Name 
			                                  ,dca.[Address] 
			                                  ,invoice.AWBNo
											  ,dca.[CompanyName]
											  ,dca.[Address]
											  ,dca.[Suburb]
											  ,dca.[State]
											  ,dca.PostCode
											  ,cu.ShortName 
			                                  ,ins.Name
											  ,dcab.[CompanyName]
											  ,dcab.[Address]
											  ,dcab.[Suburb]
											  ,dcab.[State]
											  ,dcab.PostCode
											  ,cub.ShortName
	                                ORDER BY invoice.[ModifiedDate] DESC",
                string.IsNullOrWhiteSpace(key) ? "" :
                string.Format(@"AND (dca.[Address] LIKE '%{0}%' OR [InvoiceNo] LIKE '%{0}%' OR [AWBNo] LIKE '%{0}%')", key));

            var factoryInvoices = connection.Query<NewFactoryInvoiceViewModel>(query).ToList();

            if (factoryInvoices.Count > 0)
            {
                foreach (NewFactoryInvoiceViewModel n in factoryInvoices)
                    FactoryInvoices = factoryInvoices;
                RebindInvoiceGrid();
                InvoiceGrid.Visible = true;
            }
            else
            {
                if (!IsPostBack)
                {
                    dvEmptyContent.Visible = true;
                    SearchTextBox.Visible = false;
                    btnSearch.Visible = false;
                }
                else
                {
                    FactoryInvoices = factoryInvoices;
                    RebindInvoiceGrid();
                    InvoiceGrid.Visible = false;
                    dvNoSearchResult.Visible = true;
                }
            }
        }

        private void RebindInvoiceGrid()
        {
            BindData(InvoiceGrid, FactoryInvoices);
        }
        #endregion
    }
}