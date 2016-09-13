using System;
using System.Collections.Generic;
using System.Linq;
//using Indico.BusinessObjects.Util;
using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class ReservationDetailsViewBO : BusinessObject
    {        
        #region Extension Methods
        // Put methods to manipulate Business Objects here. Add, Update etc

        internal static List<Indico.BusinessObjects.ReservationDetailsViewBO> ToList(IEnumerable<Indico.DAL.ReservationDetailsView> oQuery)
        {
            List<Indico.DAL.ReservationDetailsView> oList = oQuery.ToList();
            List<Indico.BusinessObjects.ReservationDetailsViewBO> rList = new List<Indico.BusinessObjects.ReservationDetailsViewBO>(oList.Count);
            foreach (Indico.DAL.ReservationDetailsView o in oList)
            {
                Indico.BusinessObjects.ReservationDetailsViewBO obj = new Indico.BusinessObjects.ReservationDetailsViewBO(o);
                rList.Add(obj);
            }

            return rList;
        }

        #endregion
    }
}

