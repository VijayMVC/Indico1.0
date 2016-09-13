using System;
using System.Collections.Generic;
using System.Linq;
//using Indico.BusinessObjects.Util;
using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class ReturnWeeklySummaryViewBO : BusinessObject
    {        
        #region Extension Methods
        // Put methods to manipulate Business Objects here. Add, Update etc

        internal static List<Indico.BusinessObjects.ReturnWeeklySummaryViewBO> ToList(IEnumerable<Indico.DAL.ReturnWeeklySummaryView> oQuery)
        {
            List<Indico.DAL.ReturnWeeklySummaryView> oList = oQuery.ToList();
            List<Indico.BusinessObjects.ReturnWeeklySummaryViewBO> rList = new List<Indico.BusinessObjects.ReturnWeeklySummaryViewBO>(oList.Count);
            foreach (Indico.DAL.ReturnWeeklySummaryView o in oList)
            {
                Indico.BusinessObjects.ReturnWeeklySummaryViewBO obj = new Indico.BusinessObjects.ReturnWeeklySummaryViewBO(o);
                rList.Add(obj);
            }

            return rList;
        }
        #endregion
    }
}

