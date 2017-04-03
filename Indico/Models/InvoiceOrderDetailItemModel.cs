namespace Indico.Models
{
    public class InvoiceOrderDetailItemModel
    {
        private decimal? _otherCharges;
        private decimal? _factoryPrice;
        private decimal? _indimanPrice;

        public InvoiceOrderDetailItemModel()
        {
            IsChanged = false;
        }

        public int InvoiceOrderDetailItemID { get; set; }
        public int OrderId { get; set; }
        public int OrderDetailId { get; set; }
        public string OrderType { get; set; }
        public string Distributor { get; set; }
        public string Client { get; set; }
        public string PurchaseOrder { get; set; }
        public string VisualLayout { get; set; }
        public string Pattern { get; set; }
        public string Fabric { get; set; }
        public string Material { get; set; }
        public string Gender { get; set; }
        public string AgeGroup { get; set; }
        public string SleeveShape { get; set; }
        public string SleeveLength { get; set; }
        public string ItemSubGroup { get; set; }
        public string Status { get; set; }
        public string PatternImagePath { get; set; }
        public string VLImagePath { get; set; }
        public string Number { get; set; }
        public decimal? OtherCharges
        {
            get { return _otherCharges; }
            set
            {
                _otherCharges = value;
                IsChanged = true;
            }
        }
        public decimal? FactoryPrice
        {
            get { return _factoryPrice; }
            set
            {
                _factoryPrice = value;
                IsChanged = true;
            }
        }
        public decimal? IndimanPrice
        {
            get { return _indimanPrice; }
            set
            {
                _indimanPrice = value;
                IsChanged = true;
            }
        }
        public string FactoryNotes { get; set; }
        public string IndimanNotes { get; set; }
        public decimal? FactoryCostsheetPrice { get; set; }
        public decimal? IndimanCostsheetPrice { get; set; }
        public string HSCode { get; set; }
        public string ItemName { get; set; }
        public bool IsRemoved { get; set; }
        public int? Qty { get; set; }
        public bool IsChanged { get; private set; }
        public int InvoiceID { get; set; }
        public string SizeQuantities { get; set; }
        public double Amount { get; set; }
        public double Total { get; set; }
        public double IndimanAmount { get; set; }
    }
}