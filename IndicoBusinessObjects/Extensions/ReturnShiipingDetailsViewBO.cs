using System;
using System.Collections.Generic;
using System.Linq;
//using Indico.BusinessObjects.Util;
using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class ReturnShiipingDetailsViewBO : BusinessObject
    {        
        #region Extension Methods
        // Put methods to manipulate Business Objects here. Add, Update etc

        internal static List<Indico.BusinessObjects.ReturnShiipingDetailsViewBO> ToList(IEnumerable<Indico.DAL.ReturnShiipingDetailsView> oQuery)
        {
            List<Indico.DAL.ReturnShiipingDetailsView> oList = oQuery.ToList();
            List<Indico.BusinessObjects.ReturnShiipingDetailsViewBO> rList = new List<Indico.BusinessObjects.ReturnShiipingDetailsViewBO>(oList.Count);
            foreach (Indico.DAL.ReturnShiipingDetailsView o in oList)
            {
                Indico.BusinessObjects.ReturnShiipingDetailsViewBO obj = new Indico.BusinessObjects.ReturnShiipingDetailsViewBO(o);
                rList.Add(obj);
            }

            return rList;
        }

        #endregion
    }
}

