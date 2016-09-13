using System;
using System.Collections.Generic;
using System.Linq;
using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class OrderDetailBO : BusinessObject
    {
        #region OnPropertyChange Methods
        // Put implementations of OnBusinessObjectNameBOPropertyNameChanging()
        // and OnBusinessObjectNameBOPropertyNameChanged() here
        
        #endregion
        
        #region Extension Methods
        // Put methods to manipulate Business Objects here. Add, Update etc

        public static List<ReturnWeeklyAddressDetailsBO> GetOrderDetailsAddressDetails(DateTime? weekenddate, string companyname, int shipmentmode)
        {
            using (IndicoEntities objContext = new IndicoEntities())
            {
                return ReturnWeeklyAddressDetailsBO.ToList(objContext.GetWeeklyAddressDetails(weekenddate, companyname, shipmentmode));
            }
        }

        public static List<ReturnWeeklySummaryViewBO> GetWeekSummary(DateTime? weekenddate, bool IsShipment)
        {
            using (IndicoEntities objContext = new IndicoEntities())
            {
                return ReturnWeeklySummaryViewBO.ToList(objContext.GetWeeklySummary(weekenddate, IsShipment));
            }
        }

        #endregion
    }
}

