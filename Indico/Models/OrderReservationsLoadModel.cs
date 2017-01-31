using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Indico.Models
{
    public class OrderReservationsLoadModel
    {

        public int ID { get; set;}

        public string Name { get; set; }


        public void SetName()
        {

            Name = Name + Convert.ToString(ID);

        }



    }
}