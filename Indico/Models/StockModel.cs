using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Indico.Models
{
    public class StockModel
    {
        public int Id { get; set; }

        public string Code { get; set; }
        public string Name { get; set; }

        public string Category { get; set; }

       public string SubCategory { get; set; }

        public string Colour { get; set; }

        public string Attribute { get; set;}

        public int MinLevel { get; set;}

        public string Uom { get; set;}

        public string SupplierCode { get; set;}

        public string Purchaser { get; set; }


        public int Balance { get; set; }


    }
}