
using System;
using System.Collections.Generic;
using System.Configuration;
using Indico.BusinessObjects;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using Dapper;
using Indico.Common.Extensions;
using Indico.Models;

namespace Indico.Providers.Data
{
    public static partial class DapperProvider
    {
        private static IDbConnection Connection { get { return new SqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString); } }

        public static InvoiceModel Invoice(int id)
        {
            using (var connection = Connection)
            {
                var query = string.Format(@"SELECT * FROM [dbo].[Invoice] WHERE ID = {0}", id);
                return connection.Query<InvoiceModel>(query).FirstOrDefault();
            }
        }

        public static List<InvoiceOrderDetailItemModel> InvoiceOrderDetailItemsForInvoice(int invoiceId, bool indiman = false)
        {
            using (var connection = Connection)
            {
                var query =
                string.Format(@"
                      EXEC [dbo].[SPC_GetInvoiceOrderDetailItems]
                      @InvoiceId = {0}", invoiceId);

                var items = connection.Query<InvoiceOrderDetailItemModel>(query).ToList();
                if (items.Count > 0)
                {
                    if (!indiman)
                    {
                        foreach (var item in items)
                        {
                            item.Amount = (double)(item.Qty.GetValueOrDefault() * (item.FactoryPrice.GetValueOrDefault() + item.OtherCharges));
                            item.Total = (double)(item.FactoryPrice.GetValueOrDefault() + item.OtherCharges);
                        }
                    }
                    else
                    {
                        foreach (var item in items)
                        {
                            item.Amount = (double)(item.Qty.GetValueOrDefault() * (item.IndimanPrice.GetValueOrDefault() + item.OtherCharges));
                            item.Total = (double)(item.IndimanPrice.GetValueOrDefault() + item.OtherCharges);
                        }
                    }
                }

                return items;
            }
        }

        public static List<TextValueModel> AllInvoiceStatusNames()
        {
            return GetTextValueList("SELECT [Name] AS [Text], ID AS [Value] FROM [dbo].[InvoiceStatus] ORDER BY [Name]");
        }

        public static int CreateInvoice(int weeklyProductionCapacity, int shipTo, int destinationPort, string weekEndDate, string etd, int priceTerm, int shipmentMode, int creator)
        {
            using (var connection = Connection)
            {
                var query =
                string.Format(@"
                      EXEC [dbo].[SPC_CreateInvoice]
                      @WeeklyProductionCapacity = {0}, @DistributorClientAddress = {1}, @Port = '{2}', @WeekEndDate = '{3}', @ShipmentDate = '{4}', @PaymentMethod = {5}, @ShipmentMode = {6}, @Creator = {7}",
                 weeklyProductionCapacity, shipTo, destinationPort, weekEndDate, etd, priceTerm, shipmentMode, creator);

                return connection.ExecuteScalar<int>(query);
            }
        }

        public static List<InvoiceModel> Invoice(int weeklyProductionCapacity, int shipTo, string shipmentDate)
        {
            using (var connection = Connection)
            {
                const string query =
                    @"
                    SELECT [ID]
                          ,[ShipTo]
                          ,[WeeklyProductionCapacity]
                          ,[ShipmentDate]
                      FROM [dbo].[Invoice]
                    GO WHERE ShipTo = {0} AND WeeklyProductionCapacity = {1} AND ShipmentDate= '{2}'";

                return connection.Query<InvoiceModel>(string.Format(query, shipTo, weeklyProductionCapacity, shipmentDate)).ToList();
            }
        }

        public static void UpdateInvoice(int invoice, int modifier, string invoiceNumber = "", string awbNumber = "", int? status = null, int? billTo = null, int? bank = null, string invoiceDate = null, string indimanInvoiceNumber = null, string indimanInvoiceDate = null)
        {
            using (var connection = Connection)
            {
                const string updateScript =
                    @"UPDATE [dbo].[Invoice]
                       SET {0}
                     WHERE ID = {1}";

                var updateValue = new List<string>();
                updateValue.AddRange(new[] { UpdateField("Modifier", modifier), UpdateField("ModifiedDate", (DateTime.Now).ToString("yyyy-MM-dd HH:mm:ss.fff"))
                    , UpdateField("InvoiceNo", invoiceNumber), UpdateField("AWBNo", awbNumber)
                    , UpdateField("Status", status),UpdateField("BillTo", billTo), UpdateField("Bank",bank), UpdateField("InvoiceDate",invoiceDate)
                    , UpdateField("IndimanInvoiceNo", indimanInvoiceNumber), UpdateField("IndimanInvoiceDate", indimanInvoiceDate)});

                var update = updateValue.Where(u => !string.IsNullOrWhiteSpace(u))
                    .Aggregate((c, n) => c + "," + n);

                connection.Execute(string.Format(updateScript, update, invoice));
            }
        }

        public static void UpdateChangedInvoiceOrderDetailItemPrices(List<InvoiceOrderDetailItemModel> items)
        {
            using (var connection = Connection)
            {
                var itemsToUpdate = items.Where(i => i.IsChanged).ToList();

                if (itemsToUpdate.Count > 0)
                {
                    StringBuilder updateBuilder = new StringBuilder();
                    foreach (string baseScript in itemsToUpdate.Select(item => string.Format(@"
                        UPDATE [dbo].[InvoiceOrderDetailItem]
                            SET [OtherCharges] = {0},
                            [FactoryPrice] = {1},
                            [IndimanPrice] = {2}
                            WHERE ID = {3} ", item.OtherCharges, item.FactoryPrice, item.IndimanPrice, item.InvoiceOrderDetailItemID)))
                    {
                        updateBuilder.AppendLine(baseScript);
                    }
                    string fullQueryString = updateBuilder.ToString();
                    connection.Execute(fullQueryString);
                }
            }
        }


        public static List<ShipmentkeyModel> ShipmentKeys(int weekId)
        {
            using (var connection = Connection)
            {
                var result = connection.Query<ShipmentkeyModel>(string.Format("EXEC [dbo].[SPC_GetShipmentKeys] {0}", weekId));
                return result.ToList();
            }
        }

        public static List<ReturnWeeklyAddressDetailsBO> GetOrderDetailsAddressDetails(int invoiceID)
        {
            using (var connection = Connection)
            {
                var result = connection.Query<ReturnWeeklyAddressDetailsBO>(string.Format("EXEC [dbo].[SPC_GetJKInvoiceSummaryDetails] {0}", invoiceID));
                return result.ToList();
            }
        }

        public static List<InvoiceOrderDetailsForPDfGenarating> GetInvoiceOrderdetailsForPDF(int invoiceID, int invOrderDetailsId)
        {
            using (var connection = Connection)
            {
                var result = connection.Query<InvoiceOrderDetailsForPDfGenarating>(string.Format("SELECT InvoiceID, OrderDetailID, FactoryPrice, IndimanPrice, OtherCharges FROM [dbo].[GetInvoiceOrderDetailPriceView] WHERE InvoiceID = {0} AND OrderDetailID = {1}", invoiceID, invOrderDetailsId));
                return result.ToList();
            }
        }

        public static List<JKDetailInvoiceInfoModel> GetJKDetailInvoiceInfo(int invoiceID)
        {
            using (var connection = Connection)
            {
                var result = connection.Query<JKDetailInvoiceInfoModel>(string.Format("EXEC [dbo].[SPC_GetJKDetailInvoiceInfo] {0}", invoiceID));
                return result.ToList();
            }
        }

        public static List<JKSummeryInvoiceInfoModel> GetJKDetailSummeryInvoiceInfo(int invoiceID)
        {
            using (var connection = Connection)
            {
                var result = connection.Query<JKSummeryInvoiceInfoModel>(string.Format("EXEC [dbo].[SPC_GetJKSummeryInvoiceInfo] {0}", invoiceID));
                return result.ToList();
            }
        }

        public static List<IndimanDetailInvoiceInfoModel> GetIndimanDetailInvoiceInfo(int invoiceID)
        {
            using (var connection = Connection)
            {
                var result = connection.Query<IndimanDetailInvoiceInfoModel>(string.Format("EXEC [dbo].[SPC_GetIndimanDetailInvoiceInfo] {0}", invoiceID));
                return result.ToList();
            }
        }
    }
}