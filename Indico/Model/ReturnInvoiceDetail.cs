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
    
    public partial class ReturnInvoiceDetail
    {
        public Nullable<int> Invoice { get; set; }
        public string InvoiceNo { get; set; }
        public string InvoiceDate { get; set; }
        public string ShipTo { get; set; }
        public string AWBNo { get; set; }
        public string ETD { get; set; }
        public string IndimanInvoiceNo { get; set; }
        public string ShipmentMode { get; set; }
        public string IndimanInvoiceDate { get; set; }
        public decimal FactoryRate { get; set; }
        public decimal IndimanRate { get; set; }
        public int Qty { get; set; }
        public decimal FactoryTotal { get; set; }
        public decimal IndimanTotal { get; set; }
        public Nullable<int> WeeklyProductionCapacity { get; set; }
        public string Status { get; set; }
        public string BillTo { get; set; }
    }
}
