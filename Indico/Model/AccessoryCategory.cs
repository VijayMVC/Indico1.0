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
    
    public partial class AccessoryCategory
    {
        public AccessoryCategory()
        {
            this.Accessories = new HashSet<Accessory>();
        }
    
        public int ID { get; set; }
        public string Name { get; set; }
        public string Code { get; set; }
    
        public virtual ICollection<Accessory> Accessories { get; set; }
    }
}
