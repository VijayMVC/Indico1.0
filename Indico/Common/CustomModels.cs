using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Indico.Common
{
    public class OrderDetailsView
    {
        public OrderDetailsView() { }
        public int OrderDetail { get; set; }
        public string OrderType { get; set; }
        public string VisualLayout { get; set; }
        public int VisualLayoutID { get; set; }
        public string Pattern { get; set; }
        public int PatternID { get; set; }
        public int FabricID { get; set; }
        public string Fabric { get; set; }
        public string VisualLayoutNotes { get; set; }
        public int Order { get; set; }
        public int Label { get; set; }
        public string Status { get; set; }
        public int StatusID { get; set; }
        public int Quantity { get; set; }
        public decimal DistributorEditedPrice { get; set; }
        public decimal Surcharge { get; set; }
        public decimal DistributorSurcharge { get; set; }
        public string EditedPriceRemarks { get; set; }
        public string FactoryInstructions { get; set; }
    }
    public class CostSheetDetailsView
    {
        public int CostSheet { get; set; }
        public decimal QuotedFOBCost { get; set; }
        public decimal QuotedCIF { get; set; }
        public decimal QuotedMP { get; set; }
        public decimal ExchangeRate { get; set; }
        public int PatternID { get; set; }
        public string Pattern { get; set; }
        public string NickName { get; set; }
        public string Fabric { get; set; }
        public string FabricName { get; set; }
        public string Category { get; set; }
        public decimal SMV { get; set; }
        public decimal SMVRate { get; set; }
        public decimal CalculateCM { get; set; }
        public decimal TotalFabricCost { get; set; }
        public decimal TotalAccessoriesCost { get; set; }
        public decimal HPCost { get; set; }
        public decimal LabelCost { get; set; }
        public decimal CM { get; set; }
        public decimal JKFOBCost { get; set; }
        public decimal Roundup { get; set; }
        public decimal DutyRate { get; set; }
        public decimal SubCons { get; set; }
        public decimal MarginRate { get; set; }
        public decimal Duty { get; set; }
        public decimal FOBAUD { get; set; }
        public decimal AirFregiht { get; set; }
        public decimal ImpCharges { get; set; }
        public decimal Landed { get; set; }
        public decimal MGTOH { get; set; }
        public decimal IndicoOH { get; set; }
        public decimal InkCost { get; set; }
        public decimal PaperCost { get; set; }
        public bool ShowToIndico { get; set; }
        public DateTime? ModifiedDate { get; set; }
        public DateTime? IndimanModifiedDate { get; set; }
        public string PatternNumber { get; set; }

        public int FabricID { get; set; }

    }
    public class OrdersView
    {
        public int OrderDetail { get; set; }
        public decimal EditedPrice { get; set; }
        public string OrderType { get; set; }
        public string VisualLayout { get; set; }
        public int VisualLayoutID { get; set; }
        public int PatternID { get; set; }
        public string Pattern { get; set; }
        public int FabricID { get; set; }
        public string Fabric { get; set; }
        public bool HasNotes { get; set; }
        public string Order { get; set; }
        public string OrderDetailStatus { get; set; }
        public int OrderDetailStatusID { get; set; }
        public DateTime? ShipmentDate { get; set; }
        public DateTime? SheduledDate { get; set; }
        public DateTime? RequestedDate { get; set; }
        public int Quantity { get; set; }
        public int DateDiffrence { get; set; }
        public string PurONo { get; set; }
        public string Distributor { get; set; }
        public string Coordinator { get; set; }
        public string Client { get; set; }
        public string JobName { get; set; }
        public string OrderStatus { get; set; }
        public int OrderStatusID { get; set; }
        public string Creator { get; set; }
        public int CreatorID { get; set; }
        public DateTime? CreatedDate { get; set; }
        public string Modifier { get; set; }
        public DateTime? ModifiedDate { get; set; }
        public string PaymentMethod { get; set; }
        public string ShipmentMethod { get; set; }
        public bool WeeklyShipment { get; set; }
        public string BillingAddress { get; set; }
        public string ShippingAddress { get; set; }
        public string DestinationPort { get; set; }
        public int ResolutionProfile { get; set; }
        public bool? IsAcceptedTermsAndConditions { get; set; }
        public bool FOCPenalty { get; set; }
        public string DespatchTo { get; set; }
    }
    public class JobNameDetailsView
    {
        public int ID { get; set; }
        public string Name { get; set; }
        public string ClientName { get; set; }
        public string DistributorName { get; set; }
        public string Address { get; set; }
        public string NickName { get; set; }
        public string City { get; set; }
        public string State { get; set; }
        public string PostalCode { get; set; }
        public string Country { get; set; }
        public string Phone { get; set; }
        public string Email { get; set; }
        public string Creator { get; set; }
        public string CreatedDate { get; set; }
        public string Modifier { get; set; }
        public string ModifiedDate { get; set; }
        public bool HasVisualLayouts { get; set; }
    }
}