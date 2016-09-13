using System;

namespace Indico.Models
{
    public class WeeklyBackordersSummaryModel
    {
        public string WeekNumber { get; set; }
        public DateTime WeekendDate { get; set; }
        public DateTime? OrderCutOffDate { get; set; }
        public DateTime? EstimatedDateOfDespatch { get; set; }
        public DateTime? EstimatedDateOfArrival { get; set; }
        public int PoloFirms { get; set; }
        public int PoloReservations { get; set; }
        public int PoloHolds { get; set; }
        public decimal PoloCapacity { get; set; }
        public int OuterWareFirms { get; set; }
        public decimal OuterwareCapacity { get; set; }
        public int UptoFiveItems { get; set; }
        public decimal UptoFiveItemsCapacity { get; set; }
        public int Samples { get; set; }
        public decimal SampleCapacity { get; set; }

        public int TotalPolo
        {
            get { return PoloFirms + PoloReservations + PoloHolds; }
        }

        public int WeekNo { get; set; }

        public int PoloBalance
        {
            get{ return (int)PoloCapacity - TotalPolo;}
        }
    }
}