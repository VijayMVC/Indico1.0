using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Indico.Models
{
    public class ReceiptsModel
    {
       public int ID { get; set; }
        
        public string TransactionNo { get; set;}

        public DateTime Date { get; set; }

        public int Item { get; set; }

        public string ItemName { get; set;}

        public int Quantity { get; set; }

        public void setdate()
        {
            DateTime dt = new DateTime();
            dt = Convert.ToDateTime(Date);
            //string d = dt.ToString("dd-MM-yyyy");
            //Date = d;
        }


    }
    


}