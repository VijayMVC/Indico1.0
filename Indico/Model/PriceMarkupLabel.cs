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
    
    public partial class PriceMarkupLabel
    {
        public PriceMarkupLabel()
        {
            this.LabelPriceLevelCosts = new HashSet<LabelPriceLevelCost>();
            this.LabelPriceListDownloads = new HashSet<LabelPriceListDownload>();
            this.LabelPriceMarkups = new HashSet<LabelPriceMarkup>();
        }
    
        public int ID { get; set; }
        public string Name { get; set; }
    
        public virtual ICollection<LabelPriceLevelCost> LabelPriceLevelCosts { get; set; }
        public virtual ICollection<LabelPriceListDownload> LabelPriceListDownloads { get; set; }
        public virtual ICollection<LabelPriceMarkup> LabelPriceMarkups { get; set; }
    }
}
