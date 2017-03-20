
using System;
using System.Collections.Generic;
using System.Configuration;
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
                const string query = "SELECT * FROM [dbo].[Invoice]";
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
                            item.Amount = (double)(item.Qty.GetValueOrDefault() * item.FactoryPrice.GetValueOrDefault());
                    }
                    else 
                    {
                        foreach (var item in items)
                            item.Amount = (double)(item.Qty.GetValueOrDefault() * item.IndimanPrice.GetValueOrDefault());
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

        public static void UpdateInvoice(int invoice, int modifier, string invoiceNumber = "", string awbNumber= "", int? status = null, int? billTo = null, int? bank = null, string invoiceDate = null, string indimanInvoiceNumber = null, string indimanInvoiceDate = null)
        {
            using (var connection = Connection)
            {
                const string updateScript =
                    @"UPDATE [dbo].[Invoice]
                       SET {0}
                     WHERE ID = {1}";

                var updateValue = new List<string>();
                updateValue.AddRange(new [] { UpdateField("Modifier", modifier), UpdateField("ModifiedDate", DateTime.Now.GetSQLDateString())
                    , UpdateField("InvoiceNo", invoiceNumber), UpdateField("AWBNo", awbNumber) 
                    , UpdateField("Status", status),UpdateField("BillTo", billTo), UpdateField("Bank",bank), UpdateField("InvoiceDate",invoiceDate)
                    , UpdateField("IndimanInvoiceNo", indimanInvoiceNumber), UpdateField("IndimanInvoiceDate", indimanInvoiceNumber)} );

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
                    var updateBuilder = new StringBuilder();
                    foreach (var baseScript in itemsToUpdate.Select(item => string.Format(@"
                        UPDATE [dbo].[InvoiceOrderDetailItem]
                            SET [OtherCharges] = {0},
                            [FactoryPrice] = {1},
                            [IndimanPrice] = {2}
                            WHERE ID = {3}", item.OtherCharges, item.FactoryPrice, item.IndimanPrice, item.InvoiceOrderDetailItemID)))
                    {
                        updateBuilder.AppendLine(baseScript);
                    }

                    connection.Execute(updateBuilder.ToString());
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
    }
}