//------------------------------------------------------------------------------
// <auto-generated>
//    This code was generated from a template.
//
//    Manual changes to this file may cause unexpected behavior in your application.
//    Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace Indico.Model
{
    using System;
    using System.Collections.Generic;
    
    public partial class PriceLevelCostView
    {
        public int ID { get; set; }
        public int Pattern { get; set; }
        public int FabricCode { get; set; }
        public string Number { get; set; }
        public string NickName { get; set; }
        public int Item { get; set; }
        public Nullable<int> SubItem { get; set; }
        public int CoreCategory { get; set; }
        public string FabricCodeName { get; set; }
        public string ItemSubCategory { get; set; }
        public string OtherCategories { get; set; }
        public decimal ConvertionFactor { get; set; }
        public bool EnableForPriceList { get; set; }
    }
}
