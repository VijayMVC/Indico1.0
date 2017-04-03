using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Indico.Models
{
    public class InvoiceOrderDetailsForPDfGenarating
    {
        public decimal FactoryPrice { get; set; }
        public decimal IndimanPrice { get; set; }
        public decimal OtherCharges { get; set; }
        public int InvoiceID { get; set; }
        public int OrderDetailID { get; set; }
    }
}