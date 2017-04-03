using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Indico.Models
{
    public class JKDetailInvoiceInfoModel
    {
        public string JKInvoiceNo { get; set; }
        public int ID { get; set; }
        public DateTime ShipmentDate { get; set; }
        public bool? IsAdelaideWareHouse { get; set; }
        public int Distributor { get; set; }
        public int Client { get; set; }
        public string dbo_JobName_Name { get; set; }
        public decimal? QuotedFOBCost { get; set; }
        public decimal? OC { get; set; }
        public decimal? fp { get; set; }
        public int? SumOfQty { get; set; }
        public decimal? Val { get; set; }
        public int Status { get; set; }
        public string Description { get; set; }
        public string dbo_OrderType_Name { get; set; }
        public string dbo_Company_Name { get; set; }
        public string Number { get; set; }
        public string dbo_Item_Name { get; set; }
        public string NamePrefix { get; set; }
        public string NickName { get; set; }
        public int? DespatchTo { get; set; }
        public string CompanyName { get; set; }
        public string Address { get; set; }
        public string Suburb { get; set; }
        public string State { get; set; }
        public string PostCode { get; set; }
        public string ShortName { get; set; }
        public string ContactName { get; set; }
        public string ContactPhone { get; set; }
        public string PurchaseOrderNo { get; set; }
        public string Filaments { get; set; }
        public string SizeQtys { get; set; }
        public DateTime InvoiceDate { get; set; }
    }
}