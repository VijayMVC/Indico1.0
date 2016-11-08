using System;

namespace Indico.Models
{
    public class DrillDownModel
    {
        public string Week { get; set; }
        public int Order { get; set; }
        public string PurchaseOrderNumber { get; set; }
        public string Product { get; set; }
        public int ProductID { get; set; }
        public string Pattern { get; set; }
        public int PatternID { get; set; }
        public string Fabric { get; set; }
        public int? FabricID { get; set; }
        public DateTime OrderDate { get; set; }
        public DateTime ETD { get; set; }
        public string Coodinator { get; set; }
        public string OrderType { get; set; }
        public string Distributor { get; set; }
        public string Client { get; set; }
        public int Qty { get; set; }
        public string ProductionLine { get; set; }
        public string ItemSubCat { get; set; }
        public string PrintType { get; set; }
        public string ShipTo { get; set; }
        public string Port { get; set; }
        public string Mode { get; set; }
        public string Status { get; set; }
        public int? ItemType { get; set; }
        public decimal? SMV { get; set; }
        public decimal? TotalSMV { get; set; }
        public int? BalQty { get; set; }
        public int OrgQty { get; set; }
        public int? UsedQty { get; set; }
        public int ShipQty { get; set; }
        public string Terms { get; set; }
        public string JobName { get; set; }
        public DateTime ProductCreatedDate { get; set; }
        public string IsBrandingKit { get; set; }
        public string PhotoApproval { get; set; }
        public string DetailStatus { get; set; }
    }
}