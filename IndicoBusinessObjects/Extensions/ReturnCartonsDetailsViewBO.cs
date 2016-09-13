using System;
using System.Collections.Generic;
using System.Linq;
//using Indico.BusinessObjects.Util;
using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class ReturnCartonsDetailsViewBO : BusinessObject
    {        
        #region Extension Methods
        // Put methods to manipulate Business Objects here. Add, Update etc

        internal static List<Indico.BusinessObjects.ReturnCartonsDetailsViewBO> ToList(IEnumerable<Indico.DAL.ReturnCartonsDetailsView> oQuery)
        {
            List<Indico.DAL.ReturnCartonsDetailsView> oList = oQuery.ToList();
            List<Indico.BusinessObjects.ReturnCartonsDetailsViewBO> rList = new List<Indico.BusinessObjects.ReturnCartonsDetailsViewBO>(oList.Count);
            foreach (Indico.DAL.ReturnCartonsDetailsView o in oList)
            {
                Indico.BusinessObjects.ReturnCartonsDetailsViewBO obj = new Indico.BusinessObjects.ReturnCartonsDetailsViewBO(o);
                rList.Add(obj);
            }

            return rList;
        }

        #endregion
    }
}

