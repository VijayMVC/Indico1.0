using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Indico.Models
{
    public class WeekNoWeekendDateModel
    {
        public int ID { get; set;}
       public int WeekNo { get; set;}

       public DateTime WeekendDate { get; set;}

       public string weeknoyear { get; set;}

        public void makeweeknoyear()
        {

            int yearportion = WeekendDate.Year;
            int weekportion = WeekNo;

            string wny = weekportion.ToString() + "/" + yearportion.ToString();
            weeknoyear = wny;
        }

    }
}