using System;
using System.Collections.Generic;
using System.Linq;
//using Indico.BusinessObjects.Util;
using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class ReturnBackOrdersViewBO : BusinessObject
    {        
        #region Extension Methods
        // Put methods to manipulate Business Objects here. Add, Update etc

        internal static List<Indico.BusinessObjects.ReturnBackOrdersViewBO> ToList(IEnumerable<Indico.DAL.ReturnBackOrdersView> oQuery)
        {
            List<Indico.DAL.ReturnBackOrdersView> oList = oQuery.ToList();
            List<Indico.BusinessObjects.ReturnBackOrdersViewBO> rList = new List<Indico.BusinessObjects.ReturnBackOrdersViewBO>(oList.Count);
            foreach (Indico.DAL.ReturnBackOrdersView o in oList)
            {
                Indico.BusinessObjects.ReturnBackOrdersViewBO obj = new Indico.BusinessObjects.ReturnBackOrdersViewBO(o);
                rList.Add(obj);
            }

            return rList;
        }

        #endregion
    }
}

