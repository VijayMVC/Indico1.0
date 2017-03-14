using System;

namespace Indico.Models
{
    public class WeekNoWeekendDateModel
    {
        private string _text;

        public int ID { get; set; }
        public int WeekNo { get; set; }

        public DateTime WeekendDate { get; set; }

        public string Text { get { return (_text ?? (_text = (WeekendDate.Year + "/" + WeekNo)));  } }
    }
}