

using System;

namespace Indico.Models
{
    public class FiveWeekDetailsModel
    {
        public int WeekNumber { get; set; }
        public DateTime WeekEndDate { get; set; }
        public int Capacity { get; set; }
        public int FirmOrders { get; set; }
        public int Reservations { get; set; }
        public string Week { get; set; }
        public int Samples { get; set; }
        public int TotalOrders { get { return FirmOrders + Reservations; } }
        public string TotalOrdersColor
        {
            get { return TotalOrders > Capacity ? "#e74c3c" : "#dc63ee"; }
        }

        public string TotalText
        {
            get { return (TotalOrders > Capacity) ? string.Format("{0}(+{1})",TotalOrders,TotalOrders-Capacity) : TotalOrders.ToString(); }

        }
    }
}