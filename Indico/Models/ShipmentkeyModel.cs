using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Indico.Models
{
    public class ShipmentkeyModel
    {

        public int ID { get; set;}

        public string DestinationPort { get; set;}

        public string ShipTo { get; set;}

        public int ShipmentId { get; set;}

        public DateTime ShipmentDate { get; set;}

        public int ShipmentMode { get; set; }

        public int PaymentMethod { get; set;}

        public string CompanyName { get; set;}

        public string PriceTerm { get; set;}

    }
}