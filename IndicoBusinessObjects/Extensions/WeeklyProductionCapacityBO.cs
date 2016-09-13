using System;
using System.Collections.Generic;
using System.Linq;
using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class WeeklyProductionCapacityBO : BusinessObject
    {
        #region OnPropertyChange Methods
        // Put implementations of OnBusinessObjectNameBOPropertyNameChanging()
        // and OnBusinessObjectNameBOPropertyNameChanged() here
        
        #endregion
        
        #region Extension Methods
        // Put methods to manipulate Business Objects here. Add, Update etc

        public static List<ReturnBackOrdersViewBO> GetBackOrderDetails(DateTime? WeekendDate)
        {
            using (IndicoEntities objContext = new IndicoEntities())
            {

                List<ReturnBackOrdersViewBO> lst = ReturnBackOrdersViewBO.ToList(objContext.GetBackOrders(WeekendDate));


                return lst;
            }
        }

        #endregion
    }
}

