
using System;

namespace Indico.Models
{
    public class ShipmentModeModel
    {
        public int ID { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
    }

    public class DestinationPortModel
    {
        public int ID { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
    }

    public class BankModel
    {
        public int ID { get; set; }
        public string Name { get; set; }
        public string Branch { get; set; }
        public string Number { get; set; }
        public string Address { get; set; }
        public string City { get; set; }
        public string State { get; set; }
        public string Postcode { get; set; }
        public int? Country { get; set; }
        public string AccountNo { get; set; }
        public string SwiftCode { get; set; }
        public int Creator { get; set; }
        public DateTime CreatedDate { get; set; }
        public int Modifier { get; set; }
        public DateTime ModifiedDate { get; set; }
    }
}