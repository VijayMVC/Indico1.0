
namespace Indico.Models
{
    public class NewShipmentOrderDetailSizeQtyViewModel
    {
        private decimal _otherCharges;

        private decimal _factoryPrice;

        private decimal _indimanPrice;

        public string PurchaseOrder { get; set; }

        public string OrderType { get; set; }

        public string VisualLayout { get; set; }

        public string Pattern { get; set; }

        public string Distributor { get; set; }

        public string Client { get; set; }

        public string Fabric { get; set; }

        public string Gender { get; set; }

        public string AgeGroup { get; set; }


        public int Quantity { get; set; }


        public decimal? CostSheetPrice { get; set; }

        public decimal FactoryPrice { get { return _factoryPrice; } set { _factoryPrice = value; IsChanged = true; } }

        public decimal OtherCharges { get { return _otherCharges; } set { _otherCharges = value; IsChanged = true; } }
        public decimal IndimanPrice { get { return _indimanPrice; } set { _indimanPrice = value; IsChanged = true; } }

        public decimal TotalPrice { get; set; }

        public decimal Amount { get; set; }

        public string FactoryNotes { get; set; }

        public bool IsRemoved { get; set; }

        public int InvoiceOrderDetailItemID { get; set; }

        public int Invoice { get; set; }

        public bool IsChanged { get; set; }

    }
}