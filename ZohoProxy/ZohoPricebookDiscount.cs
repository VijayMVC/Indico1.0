using System.ComponentModel;

namespace ZohoProxy
{
    public class ZohoPricebookDiscount
    {
        [Description("Model Id")]
        public string ModuleId;

        [Description("From Range")]
        public decimal FromRange;

        [Description("To Range")]
        public decimal ToRange;

        [Description("Discount")]
        public decimal Discount;
    }
}
