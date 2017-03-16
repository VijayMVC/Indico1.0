using System;

namespace Indico.Models
{
    public class NewShipmentOrderDetailSizeQtyViewModel
    {
        public string PurchaseOrderNumber { get; set; }
        public string OrderType { get; set; }
        public string VisualLayout { get; set; }
        public string Pattern { get; set; }
        public string Distributor { get; set; }
        public string Client { get; set; }
        public string Fabric { get; set; }
        public string Gender { get; set; }
        public string AgeGroup { get; set; }
        public string SizeDescription { get; set; }
        public int SizeQuantity { get; set; }
        public int SizeSrNumber { get; set; }
        public decimal? CostsheetPrice { get; set; }
        public decimal FactoryPrice { get; set; }
        public decimal TotalPrice { get; set; }
        public decimal Amount { get; set; }
        public string Notes { get; set; }
    }
}