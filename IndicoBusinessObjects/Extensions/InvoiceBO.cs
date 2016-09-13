using System;
using System.Collections.Generic;
using System.Linq;
using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class InvoiceBO : BusinessObject
    {
        #region OnPropertyChange Methods
        // Put implementations of OnBusinessObjectNameBOPropertyNameChanging()
        // and OnBusinessObjectNameBOPropertyNameChanged() here

        #endregion

        #region Extension Methods
        // Put methods to manipulate Business Objects here. Add, Update etc

        public static List<ReturnInvoiceOrderDetailViewBO> InvoiceOrderDetailView(int? Invoice, int? ShipTo, bool? IsNew, DateTime? WeekEndDate, int? ShipmentMode)
        {
            using (IndicoEntities objContext = new IndicoEntities())
            {
                List<ReturnInvoiceOrderDetailViewBO> lst = ReturnInvoiceOrderDetailViewBO.ToList(objContext.GetInvoiceOrderDetails(Invoice, ShipTo, IsNew, WeekEndDate, ShipmentMode));
                return lst;
            }
        }

        public static List<ReturnShipmentDatesViewBO> GetShipmentDates(DateTime? WeekEndDate)
        {
            using (IndicoEntities objContext = new IndicoEntities())
            {
                List<ReturnShipmentDatesViewBO> lst = ReturnShipmentDatesViewBO.ToList(objContext.GetShipmentDates(WeekEndDate));
                return lst;
            }
        }

        #endregion
    }
}

