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
    
    public partial class OrderDetailQty
    {
        public int ID { get; set; }
        public int OrderDetail { get; set; }
        public int Size { get; set; }
        public int Qty { get; set; }
    
        public virtual OrderDetail OrderDetail1 { get; set; }
        public virtual Size Size1 { get; set; }
    }
}
