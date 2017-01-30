using System;

namespace Indico.Models
{
    public class WeeklySmvSummariesModel
    {
        public int WeekNumber { get; set; }
        public DateTime WeekEndDate { get; set; }
        public DateTime OrderCutOffDate { get; set; }
        public DateTime EstimatedDateOfDespatch { get; set; }
        public DateTime EstimatedDateOfArrival { get; set; }
        public int NumberOfHoliDays { get; set; }
        public decimal PoloCapacity { get; set; }
        public decimal PoloFivePcsCapacity { get; set; }
        public decimal PoloSampleCapacity { get; set; }
        public int PoloWorkers { get; set; }
        public decimal PoloEfficiency { get; set; }
        public int PoloFirms { get; set; }
        public int PoloReservations { get; set; }
        public int PoloHolds { get; set; }
        public int PoloUptoFiveItems { get; set; }
        public int PoloSamples { get; set; }
        public decimal OuterwareCapacity { get; set; }
        public decimal OuterwareFivePcsCapacity { get; set; }
        public decimal OuterwareSampleCapacity { get; set; }
        public int OuterwareWorkers { get; set; }
        public decimal OuterwareEfficiency { get; set; }
        public int OuterWareFirms { get; set; }
        public int OuterwareReservations { get; set; }
        public int OuterwareHolds { get; set; }
        public int OuterwareUptoFiveItems { get; set; }
        public int OuterwareSamples { get; set; }
        public int TotalFirm { get { return OuterWareFirms + PoloFirms; } }
        public decimal TotalCapacity { get { return PoloCapacity + OuterwareCapacity; } }
        public int PoloTotal { get { return PoloReservations + PoloFirms; } }
        public int OuterwareTotal { get { return OuterWareFirms + OuterwareReservations; } }
    }
}