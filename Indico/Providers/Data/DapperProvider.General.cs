using System;
using System.Collections.Generic;
using System.Linq;
using Dapper;
using Indico.Models;

namespace Indico.Providers.Data
{
    public static partial class DapperProvider
    {

        public static List<TextValueModel> AllDistributorClientAddressNames()
        {
            using (var connection = Connection)
            {
                return connection.Query<TextValueModel>(
                string.Format(@"SELECT dca.CompanyName + ' ' +  dca.[Address] + ' ' + dca.PostCode + ' ' +  dca.Suburb + ' ' + dca.[State] + dca.Country AS Text, dca.ID AS Value
	                    FROM [dbo].[DistributorClientAddressDetailsView] dca")).ToList();
            }
        }

        public static DistributorClientAddressModel DistributorClientAddress(int id)
        {
            using (var connection = Connection)
            {
                return connection.Query<DistributorClientAddressModel>(
                    string.Format(@"SELECT TOP 1 * FROM [dbo].[DistributorClientAddress] WHERE ID = " + id)).FirstOrDefault();
            }
        }

        public static List<TextValueModel> AllBankNames()
        {
            return GetTextValueList("SELECT [Name] AS [Text], ID AS [Value] FROM [dbo].[Bank] ORDER BY [Name]");
        }


        public static List<TextValueModel> AllShipmentModeNames()
        {
            return GetTextValueList("SELECT [Name] AS [Text], ID AS [Value] FROM [dbo].[ShipmentMode] ORDER BY [Name]");
        }

        public static List<TextValueModel> AllDestinationPortNames()
        {
            return GetTextValueList("SELECT [Name] AS [Text], ID AS [Value] FROM [dbo].[DestinationPort] ORDER BY [Name]");
        }


        public static List<WeekNoWeekendDateModel> GetWeekNames(int year)
        {
            using (var connection = Connection)
            {
                const string query =
                    @"SELECT * FROM [dbo].WeeklyProductionCapacity WHERE WeekendDate <= DATEADD(MONTH ,1 , GETDATE()) AND DATEPART(yyyy, WeekendDate) >= {0} ORDER BY DATEPART(yyyy, WeekendDate) , WeekNo ";
                return connection.Query<WeekNoWeekendDateModel>(string.Format(query, year)).ToList();
            }
        }

        public static CountryModel Country(int id)
        {
            return IDWhere<CountryModel>("Country", id);
        }

        public static ShipmentModeModel ShipmentMode(int id)
        {
            return IDWhere<ShipmentModeModel>("ShipmentMode", id);
        }

        public static DestinationPortModel DestinationPort(int id)
        {
            return IDWhere<DestinationPortModel>("DestinationPort", id);
        }

        public static BankModel Bank(int id)
        {
            return IDWhere<BankModel>("Bank", id);
        }

        private static List<TextValueModel> GetTextValueList(string query)
        {
            using (var connection = Connection)
            {
                return connection.Query<TextValueModel>(query).ToList();
            }
        }

        private  static T IDWhere<T>(string tableName, int id)
        {
            using (var connection = Connection)
            {
                return connection.Query<T>(string.Format("SELECT * FROM [dbo].[{0}] WHERE ID = {1}", tableName, id)).FirstOrDefault();
            }
        }


        private static string UpdateField(string columnName, object value)
        {
            if (string.IsNullOrWhiteSpace(columnName) || value == null)
                return "";

            return string.Format("[{0}] = {1}{2}{1}", columnName, (value is string || value is DateTime) ? "'" : "", value);
        }
    }
}