using System;
using System.Collections.Generic;
using System.Linq;
//using Indico.BusinessObjects.Util;
using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class ReturnDistributorDetailsViewBO : BusinessObject
    {        
        #region Extension Methods
        // Put methods to manipulate Business Objects here. Add, Update etc

        internal static List<Indico.BusinessObjects.ReturnDistributorDetailsViewBO> ToList(IEnumerable<Indico.DAL.ReturnDistributorDetailsView> oQuery)
        {
            List<Indico.DAL.ReturnDistributorDetailsView> oList = oQuery.ToList();
            List<Indico.BusinessObjects.ReturnDistributorDetailsViewBO> rList = new List<Indico.BusinessObjects.ReturnDistributorDetailsViewBO>(oList.Count);
            foreach (Indico.DAL.ReturnDistributorDetailsView o in oList)
            {
                Indico.BusinessObjects.ReturnDistributorDetailsViewBO obj = new Indico.BusinessObjects.ReturnDistributorDetailsViewBO(o);
                rList.Add(obj);
            }

            return rList;
        }

        #endregion
    }
}

