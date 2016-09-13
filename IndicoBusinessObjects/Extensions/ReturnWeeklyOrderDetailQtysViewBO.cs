using System;
using System.Collections.Generic;
using System.Linq;
//using Indico.BusinessObjects.Util;
using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class ReturnWeeklyOrderDetailQtysViewBO : BusinessObject
    {        
        #region Extension Methods
        // Put methods to manipulate Business Objects here. Add, Update etc

        internal static List<Indico.BusinessObjects.ReturnWeeklyOrderDetailQtysViewBO> ToList(IEnumerable<Indico.DAL.ReturnWeeklyOrderDetailQtysView> oQuery)
        {
            List<Indico.DAL.ReturnWeeklyOrderDetailQtysView> oList = oQuery.ToList();
            List<Indico.BusinessObjects.ReturnWeeklyOrderDetailQtysViewBO> rList = new List<Indico.BusinessObjects.ReturnWeeklyOrderDetailQtysViewBO>(oList.Count);
            foreach (Indico.DAL.ReturnWeeklyOrderDetailQtysView o in oList)
            {
                Indico.BusinessObjects.ReturnWeeklyOrderDetailQtysViewBO obj = new Indico.BusinessObjects.ReturnWeeklyOrderDetailQtysViewBO(o);
                rList.Add(obj);
            }

            return rList;
        }
        #endregion
    }
}

