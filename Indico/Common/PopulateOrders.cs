using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI.HtmlControls;

namespace Indico.Common
{
    public class PopulateOrders
    {
        #region Fields
        #endregion

        #region Properties

        #region Order
        //Order
        public string OrderNumber { get; set; }
        public DateTime Date { get; set; }
        public DateTime DesiredDate { get; set; }
        public DateTime? ShipmentDate { get; set; }

        public int Distributor { get; set; }
        public int MYOBCardFile { get; set; }
        public int Client { get; set; }
        public int JobName { get; set; }
        public string AccessPONo { get; set; }
        public string DistributorPONo { get; set; }
        public int PaymentMethod { get; set; }
        public bool isPhotoApprovalRequired { get; set; }
        public bool IsBrandingKit { get; set; }
        public bool IsLockerPatch { get; set; }
        public int OrderStatus { get; set; }
        public int ShipmentMode { get; set; }
        public int DeliveryOption { get; set; }

        public int OrderType { get; set; }
        public int Label { get; set; }
        public bool IsRepeat { get; set; }
        public int Reservations { get; set; }
        public int VisualLayout { get; set; }
        public int ArtWork { get; set; }
        public string OrderNotes { get; set; }
        public string PromoCode { get; set; }

        //Shipment Mode
        public bool IsWeeklyShipment { get; set; }
        public bool IsCourier { get; set; }

        public int BillingAddress { get; set; }
        public int DespatchAddress { get; set; }
        public int CourierAddress { get; set; }

        #endregion

        //VisualLayout 
        #region VisualLayout

        public bool IsCommonProduct { get; set; }
        public bool IsGenerate { get; set; }
        public bool IsCustom { get; set; }
        public int printerType { get; set; }
        public string productNumber { get; set; }
        public int vlDistributor { get; set; }
        public int Fabric { get; set; }
        public int Pattern { get; set; }
        public string Notes { get; set; }
        public HtmlInputHidden imageHiddenField { get; set; }

        #endregion

        #endregion

        #region Constructor
        #endregion

        #region Methods
        #endregion
    }
}