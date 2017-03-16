using System.ComponentModel;

namespace ZohoProxy
{
    public class ZohoProduct
    {
        [Description("ProductID")]
        public int ProductID { get; set; }

        [Description("PatternID")]
        public int PatternID { get; set; }

        [Description("PatternCode")]
        public string PatternCode { get; set; }

        [Description("Pattern Description")]
        public string PatternDescription { get; set; }

        [Description("FabricID")]
        public int FabricID { get; set; }

        [Description("FabricCode")]
        public string FabricCode { get; set; }

        [Description("Fabric Description")]
        public string FabricDescription { get; set; }

        [Description("IndimanPrice")]
        public double IndimanPrice { get; set; }

        [Description("Suggested Price")]
        public double SuggestedPrice { get; set; }
    }
}
