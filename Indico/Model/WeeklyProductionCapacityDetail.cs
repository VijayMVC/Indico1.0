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
    
    public partial class WeeklyProductionCapacityDetail
    {
        public int ID { get; set; }
        public int WeeklyProductionCapacity { get; set; }
        public int ItemType { get; set; }
        public Nullable<decimal> TotalCapacity { get; set; }
        public Nullable<decimal> FivePcsCapacity { get; set; }
        public Nullable<decimal> SampleCapacity { get; set; }
        public Nullable<int> Workers { get; set; }
        public Nullable<decimal> Efficiency { get; set; }
    
        public virtual ItemType ItemType1 { get; set; }
        public virtual WeeklyProductionCapacity WeeklyProductionCapacity1 { get; set; }
    }
}
