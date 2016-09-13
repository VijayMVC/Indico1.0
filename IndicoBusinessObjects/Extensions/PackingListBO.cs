using System;
using System.Collections.Generic;
using System.Linq;
using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class PackingListBO : BusinessObject
    {
        #region OnPropertyChange Methods
        // Put implementations of OnBusinessObjectNameBOPropertyNameChanging()
        // and OnBusinessObjectNameBOPropertyNameChanged() here

        #endregion

        #region Extension Methods
        // Put methods to manipulate Business Objects here. Add, Update etc

        public static ReturnIntViewBO InsertPackingList(DateTime weekenddate, int creator)
        {
            using (IndicoEntities objContext = new IndicoEntities())
            {
                return ReturnIntViewBO.ToList(objContext.CreatePackingList(weekenddate, creator))[0];
            }
        }

        public static List<PackingListViewBO> GetPackingList(DateTime weekendDate, int shipmentmode, int shippingaddress)
        {
            using (IndicoEntities objContext = new IndicoEntities())
            {
                List<PackingListViewBO> lst = PackingListViewBO.ToList(objContext.GetPackingListDetails(weekendDate, shipmentmode, shippingaddress));
                
                return lst;
            }
        }

        public static List<ReturnCartonsDetailsViewBO> GetCartonsDetails(DateTime weekendDate)
        {
            using (IndicoEntities objContext = new IndicoEntities())
            {
                List<ReturnCartonsDetailsViewBO> lst = ReturnCartonsDetailsViewBO.ToList(objContext.GetCartonsDetails(weekendDate));

                return lst;
            }
        }

        public static List<ReturnShippingAddressWeekendDateBO> GetShippingAddressWeekendDate(DateTime weekendDate)
        {
            using (IndicoEntities objContext = new IndicoEntities())
            {
                List<ReturnShippingAddressWeekendDateBO> lst = ReturnShippingAddressWeekendDateBO.ToList(objContext.GetShippingAddressWeekendDate(weekendDate));

                return lst;
            }
        }

        #endregion
    }
}

