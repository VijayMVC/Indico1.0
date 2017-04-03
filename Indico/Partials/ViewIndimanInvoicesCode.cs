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
    public partial class ViewIndimanInvoices
    {
        #region Fields

        #endregion

        #region Properties 
        private List<NewIndimanInvoiceViewModel> IndimanInvoices { get { return Session["IndimanInvoices"] as List<NewIndimanInvoiceViewModel>; } set { Session["IndimanInvoices"] = value; } }
        #endregion

        #region UI Event 
        protected void OnInvoiceGridDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if ((item.ItemIndex > -1 && item.DataItem is NewIndimanInvoiceViewModel))
                {
                    var objInvoice = (NewIndimanInvoiceViewModel)item.DataItem;

                    var linkEdit = GetControl<HyperLink>(item, "linkEdit");
                    linkEdit.NavigateUrl = "/AddEditInvoice.aspx?id=" + objInvoice.Invoice.ToString() + "&Type=i";

                    var btnIndimanInvoice = GetControl<LinkButton>(item, "btnIndimanInvoice");
                    btnIndimanInvoice.Attributes.Add("qid", objInvoice.Invoice.ToString());
                }
            }
        }
        #endregion

        #region Peivate function

        private void PopulateDataGrid()
        {
            if (txtSearch.Text == null || txtSearch.Text == "")
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
                    LoadFactoryInvoiceDateGrid(connection, txtSearch.Text);
                }
            }
        }
        private void LoadFactoryInvoiceDateGrid(IDbConnection connection, string key = null)
        {
            dvEmptyContent.Visible = false;
            dvNoSearchResult.Visible = false;
            txtSearch.Visible = true;

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
			                            ,SUM(qi.Qty*(inv.IndimanPrice+inv.OtherCharges)) AS IndimanTotal
	                            FROM [dbo].[Invoice] invoice
	                                INNER JOIN  [dbo].[InvoiceOrderDetailItem] inv
			                            ON invoice.ID = inv.Invoice
		                            INNER JOIN [Indico].[dbo].[ShipmentMode] sm
			                            ON  invoice.ShipmentMode = sm.[ID]
		                            INNER JOIN [dbo].[DistributorClientAddress] dca
		                                ON invoice.ShipTo = dca.[ID]
									INNER JOIN [dbo].[Country] cu
											ON dca.Country = cu.ID
									INNER JOIN [dbo].[DistributorClientAddress] dcab
		                                ON invoice.BillTo = dcab.[ID]
									INNER JOIN [dbo].[Country] cub
											ON dcab.Country = cub.ID
		                            INNER JOIN [dbo].[InvoiceStatus] ins
                                        ON  invoice.[Status] = ins.ID
		                            INNER JOIN #QtyInfo qi
			                            ON inv.ID = qi.InvoiceOrderDetailItemID		
		                            INNER JOIN [Indico].[dbo].[OrderDetail] od
			                            ON inv.OrderDetail = od.ID
		                            INNER JOIN [Indico].[dbo].[Order] o
			                            ON od.[Order] = o.ID
		                            INNER JOIN [Indico].[dbo].[OrderStatus] os
			                            ON o.[Status] = os.ID		
	                            WHERE ([InvoiceNo] <> '' OR [InvoiceNo] <> NULL)  AND ([IndimanInvoiceNo] <> NULL OR [IndimanInvoiceNo] <> '' ) {0}
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
			                            ,invoice.AWBNo
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

            var indimanInvoices = connection.Query<NewIndimanInvoiceViewModel>(query).ToList();

            if (indimanInvoices.Count > 0)
            {
                foreach (NewIndimanInvoiceViewModel n in indimanInvoices)
                    IndimanInvoices = indimanInvoices;
                RebindInvoiceGrid();
                RadIndimanInvoice.Visible = true;
            }
            else
            {
                if (!IsPostBack)
                {
                    dvEmptyContent.Visible = true;
                    txtSearch.Visible = false;
                    btnSearch.Visible = false;
                }
                else
                {
                    IndimanInvoices = indimanInvoices;
                    RebindInvoiceGrid();
                    RadIndimanInvoice.Visible = false;
                    dvNoSearchResult.Visible = true;
                }
            }
        }

        private void RebindInvoiceGrid()
        {
            BindData(RadIndimanInvoice, IndimanInvoices);
        }
        #endregion
    }
}