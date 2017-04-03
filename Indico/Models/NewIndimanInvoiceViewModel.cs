using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Indico.Models
{
    public class NewIndimanInvoiceViewModel
    {
        public int Invoice { get; set; }
        public string InvoiceNo { get; set; }
        public string IndimanInvoiceNo { get; set; }
        public DateTime? InvoiceDate { get; set; }
        public DateTime? IndimanInvoiceDate { get; set; }
        public DateTime ETD { get; set; }
        public string ShipTo { get; set; }
        public string ShipmentMode { get; set; }
        public string AWBNo { get; set; }
        public string BillTo { get; set; }
        public string Status { get; set; }
        public int? Qty { get; set; }
        public decimal? IndimanTotal { get; set; }
    }
}