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
    
    public partial class SPC_GetBackOrders_Result
    {
        public int DistributorID { get; set; }
        public string Distributor { get; set; }
        public string Coordinator { get; set; }
        public Nullable<int> CoordinatorID { get; set; }
        public bool BackOrder { get; set; }
        public Nullable<int> Qty { get; set; }
        public string DistributorEmailAddress { get; set; }
        public string CoordinatorEmailAddress { get; set; }
        public int Count { get; set; }
    }
}
