using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Indico.Models
{
    public class JKSummeryInvoiceInfoModel
    {
        public DateTime InvoiceDate { get; set; }
        public string JkInvoiceNo { get; set; }
        public int? SumOfQty { get; set; }
        public decimal? Val { get; set; }
        public string CompanyName { get; set; }
        public string Address { get; set; }
        public string Suburb { get; set; }
        public string State { get; set; }
        public string PostCode { get; set; }
        public string ShortName { get; set; }
        public string ContactName { get; set; }
        public string ContactPhone { get; set; }
        public string dbo_Item_Name { get; set; }
        public string Filaments { get; set; }
        public string HS_Code { get; set; }
        public string Gender { get; set; }
    }
}