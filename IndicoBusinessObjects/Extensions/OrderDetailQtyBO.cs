using System;
using System.Collections.Generic;
using System.Linq;
using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class OrderDetailQtyBO : BusinessObject
    {
        #region OnPropertyChange Methods
        // Put implementations of OnBusinessObjectNameBOPropertyNameChanging()
        // and OnBusinessObjectNameBOPropertyNameChanged() here

        #endregion

        #region Extension Methods
        // Put methods to manipulate Business Objects here. Add, Update etc

        public static List<ReturnWeeklyOrderDetailQtysViewBO> WeeklyOrderDetailQtys(DateTime weekenddate)
        {
            using (IndicoEntities objContext = new IndicoEntities())
            {
                List<ReturnWeeklyOrderDetailQtysViewBO> lst = ReturnWeeklyOrderDetailQtysViewBO.ToList(objContext.GetWeeklyOrderDetailQtys(weekenddate));

                return lst;
            }
        }

        #endregion
    }
}

