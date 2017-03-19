using System;

namespace Indico.Models
{
    public class InvoiceModel
    {
        public int ID { get; set; }
        public string InvoiceNo { get; set; }
        public DateTime InvoiceDate { get; set; }
        public int? ShipTo { get; set; }
        public string AWBNo { get; set; }
        public int WeeklyProductionCapacity { get; set; }
        public string IndimanInvoiceNo { get; set; }
        public int ShipmentMode { get; set; }
        public DateTime? IndimanInvoiceDate { get; set; }
        public int Creator { get; set; }
        public DateTime CreatedDate { get; set; }
        public int Modifier { get; set; }
        public DateTime ModifiedDate { get; set; }
        public int Status { get; set; }
        public DateTime ShipmentDate { get; set; }
        public int? BillTo { get; set; }
        public bool? IsBillTo { get; set; }
        public int? Bank { get; set; }
    }
}