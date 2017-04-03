using System;

namespace Indico.Models
{
    public class ShipmentkeyModel
    {
        public int ID { get; set; }
        public string DestinationPort { get; set; }
        public int ShipTo { get; set; }
        public DateTime ShipmentDate { get; set; }
        public string ShipmentMethod { get; set; }
        public string CompanyName { get; set; }
        public string PriceTerm { get; set; }
        public int ShipmentModeID { get; set; }
        public int ShipToID { get; set; }
        public int PriceTermID { get; set; }
        public int Qty { get; set; }
        public int PortID { get; set; }
    }
}