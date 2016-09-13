using System;

namespace Indico.Models
{
    public class OrderDrillDownMedel
    {
        public string Week { get; set; }
        public string PurchaseOrderNumber { get; set; }
        public string VlName { get; set; }
        public string Pattern { get; set; }
        public string Fabric { get; set; }
        public DateTime OrderDate { get; set; }
        public DateTime ETD { get; set; }
        public string Coodinator { get; set; }
        public string OrderType { get; set; }
        public string Distributor { get; set; }
        public string Client { get; set; }
        public decimal Quantity { get; set; }
        public string ProductionLine { get; set; }
        public string SubItemName { get; set; }
        public string PrintType { get; set; }
        public string ShipTo { get; set; }
        public string Port { get; set; }
        public string Mode { get; set; }
        public string Status { get; set; }
        public decimal SMV { get; set; }
        public decimal TotalSMV { get; set; }
    }
}