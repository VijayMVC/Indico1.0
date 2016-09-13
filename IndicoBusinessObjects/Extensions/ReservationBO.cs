using System;
using System.Collections.Generic;
using System.Linq;
using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class ReservationBO : BusinessObject
    {
        #region OnPropertyChange Methods
        // Put implementations of OnBusinessObjectNameBOPropertyNameChanging()
        // and OnBusinessObjectNameBOPropertyNameChanged() here
        
        #endregion
        
        #region Extension Methods
        // Put methods to manipulate Business Objects here. Add, Update etc

        public static List<ReservationDetailsViewBO> GetReservationDetails(DateTime? weekEndDate, string searchText, string status, string distributor, string coordinator)
        {
            using (IndicoEntities objContext = new IndicoEntities())
            {
                System.Data.Objects.ObjectParameter recCount = new System.Data.Objects.ObjectParameter("P_RecCount", typeof(int));
                List<ReservationDetailsViewBO> lst = ReservationDetailsViewBO.ToList(objContext.GetReservationDetails(searchText, weekEndDate, status, distributor, coordinator));
                //total = (int)recCount.Value;

                return lst;
            }
        }

        #endregion
    }
}

