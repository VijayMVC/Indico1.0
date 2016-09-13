using System;
using System.Collections.Generic;
using System.Linq;
//using Indico.BusinessObjects.Util;
using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class ReturnIntViewBO : BusinessObject
    {        
        #region Extension Methods
        // Put methods to manipulate Business Objects here. Add, Update etc

        internal static List<Indico.BusinessObjects.ReturnIntViewBO> ToList(IEnumerable<Indico.DAL.ReturnIntView> oQuery)
        {
            List<Indico.DAL.ReturnIntView> oList = oQuery.ToList();
            List<Indico.BusinessObjects.ReturnIntViewBO> rList = new List<Indico.BusinessObjects.ReturnIntViewBO>(oList.Count);
            foreach (Indico.DAL.ReturnIntView o in oList)
            {
                Indico.BusinessObjects.ReturnIntViewBO obj = new Indico.BusinessObjects.ReturnIntViewBO(o);
                rList.Add(obj);
            }

            return rList;
        }

        #endregion
    }
}

