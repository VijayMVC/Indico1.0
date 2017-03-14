using System;

namespace Indico.Models
{
    public class ReservationBalanceModel
    {
        public int ID { get; set; }

        public DateTime ReservationDate { get; set; }

        public string Pattern { get; set; }

        public string Coordinator { get; set; }

        public string Distributor { get; set; }

        public string Client { get; set; }

        public DateTime ShipmentDate { get; set; }

        public int Qty { get; set; }

        public int Total { get; set;}

        public int Balance { get; set; }

        public string Status { get; set; }

        public string Notes { get; set; }

        public int? QtyPolo { get; set; }

        public int? QtyOutwear { get; set;}

        public int ReservationNo { get; set; }
        public DateTime OrderDate { get; set; }
    }
}