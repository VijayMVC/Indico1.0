using System;
using System.Collections.Generic;
using System.Linq;
//using Indico.BusinessObjects.Util;
using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class ReturnOrderDetailsIndicoPriceViewBO : BusinessObject
    {        
        #region Extension Methods
        // Put methods to manipulate Business Objects here. Add, Update etc

        internal static List<Indico.BusinessObjects.ReturnOrderDetailsIndicoPriceViewBO> ToList(IEnumerable<Indico.DAL.ReturnOrderDetailsIndicoPriceView> oQuery)
        {
            List<Indico.DAL.ReturnOrderDetailsIndicoPriceView> oList = oQuery.ToList();
            List<Indico.BusinessObjects.ReturnOrderDetailsIndicoPriceViewBO> rList = new List<Indico.BusinessObjects.ReturnOrderDetailsIndicoPriceViewBO>(oList.Count);
            foreach (Indico.DAL.ReturnOrderDetailsIndicoPriceView o in oList)
            {
                Indico.BusinessObjects.ReturnOrderDetailsIndicoPriceViewBO obj = new Indico.BusinessObjects.ReturnOrderDetailsIndicoPriceViewBO(o);
                rList.Add(obj);
            }

            return rList;
        }
        #endregion
    }
}

