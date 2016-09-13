using System;
using System.Collections.Generic;
using System.Linq;
//using Indico.BusinessObjects.Util;
using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class OrderDetailsViewBO : BusinessObject
    {
        #region Extension Methods
        // Put methods to manipulate Business Objects here. Add, Update etc

        internal static List<Indico.BusinessObjects.OrderDetailsViewBO> ToList(IEnumerable<Indico.DAL.OrderDetailsView> oQuery)
        {
            List<Indico.DAL.OrderDetailsView> oList = oQuery.ToList();
            List<Indico.BusinessObjects.OrderDetailsViewBO> rList = new List<Indico.BusinessObjects.OrderDetailsViewBO>(oList.Count);
            foreach (Indico.DAL.OrderDetailsView o in oList)
            {
                Indico.BusinessObjects.OrderDetailsViewBO obj = new Indico.BusinessObjects.OrderDetailsViewBO(o);
                rList.Add(obj);
            }

            return rList;
        }

        #endregion
    }
}

