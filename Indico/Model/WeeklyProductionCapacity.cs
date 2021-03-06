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
    
    public partial class WeeklyProductionCapacity
    {
        public WeeklyProductionCapacity()
        {
            this.DistributorSendMailCounts = new HashSet<DistributorSendMailCount>();
            this.Invoices = new HashSet<Invoice>();
            this.PackingLists = new HashSet<PackingList>();
            this.ProductionPlannings = new HashSet<ProductionPlanning>();
            this.WeeklyProductionCapacityDetails = new HashSet<WeeklyProductionCapacityDetail>();
        }
    
        public int ID { get; set; }
        public int WeekNo { get; set; }
        public System.DateTime WeekendDate { get; set; }
        public int Capacity { get; set; }
        public string Notes { get; set; }
        public int NoOfHolidays { get; set; }
        public Nullable<decimal> SalesTarget { get; set; }
        public Nullable<decimal> HoursPerDay { get; set; }
        public Nullable<System.DateTime> OrderCutOffDate { get; set; }
        public Nullable<System.DateTime> EstimatedDateOfDespatch { get; set; }
        public Nullable<System.DateTime> EstimatedDateOfArrival { get; set; }
    
        public virtual ICollection<DistributorSendMailCount> DistributorSendMailCounts { get; set; }
        public virtual ICollection<Invoice> Invoices { get; set; }
        public virtual ICollection<PackingList> PackingLists { get; set; }
        public virtual ICollection<ProductionPlanning> ProductionPlannings { get; set; }
        public virtual ICollection<WeeklyProductionCapacityDetail> WeeklyProductionCapacityDetails { get; set; }
    }
}
