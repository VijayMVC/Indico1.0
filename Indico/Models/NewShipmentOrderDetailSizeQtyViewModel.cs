using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Indico.Models
{
    public class NewShipmentOrderDetailSizeQtyViewModel
    {

        public int Order { get; set; }

        public int OrderDetail { get; set; }

        public int ordertype { get; set; }
        
        public string ordertypename { get; set; }

        public int VisualLayout { get; set; }

        public string NamePrefix { get; set; }

        public int Distributor { get; set; }

        public string DistributorName { get; set; }

        public int Client { get; set; }

        public string ClientName { get; set; }

        public int Pattern { get; set; }

        public string PatternName { get; set;}

        public int FabricCode { get; set; }

        public string FabricName { get; set; }

        public int Gender { get; set; }

        public string GenderName { get; set; }
        public int AgeGroup { get; set; }
        public string AgeGroupName { get; set; }

        public double FactoryCost { get; set; }

        public double IndimanCost { get; set; }

        public int Size { get; set; }

        public int Qty { get; set; }

        public int Port { get; set; }
        public string PortName { get; set; }

        public int ShipTo { get; set; }

        public string ShiptoName { get; set; }

        public DateTime ShipmentDate { get; set; }

        public int PaymentMethod { get; set; }

        public string PaymentMehodName { get; set; }

        public double OtherCharges { get; set; }

        public double FactoryPrice { get; set;}

        public double TotalPrice { get; set; }

        public double Amount { get; set;}

        public string Notes { get; set;}

  
    }
}