using System;

namespace Indico.Common.Extensions
{
    public static class DateTimeExtensions
    {
        public static string GetSQLDateString(this DateTime dateTime)
        {
            return dateTime.ToString("yyyyMMdd");
        }
    }
}