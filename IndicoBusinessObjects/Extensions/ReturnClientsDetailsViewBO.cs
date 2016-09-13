using System;
using System.Collections.Generic;
using System.Linq;
//using Indico.BusinessObjects.Util;
using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class ReturnClientsDetailsViewBO : BusinessObject
    {        
        #region Extension Methods
        // Put methods to manipulate Business Objects here. Add, Update etc

        internal static List<Indico.BusinessObjects.ReturnClientsDetailsViewBO> ToList(IEnumerable<Indico.DAL.ReturnClientsDetailsView> oQuery)
        {
            List<Indico.DAL.ReturnClientsDetailsView> oList = oQuery.ToList();
            List<Indico.BusinessObjects.ReturnClientsDetailsViewBO> rList = new List<Indico.BusinessObjects.ReturnClientsDetailsViewBO>(oList.Count);
            foreach (Indico.DAL.ReturnClientsDetailsView o in oList)
            {
                Indico.BusinessObjects.ReturnClientsDetailsViewBO obj = new Indico.BusinessObjects.ReturnClientsDetailsViewBO(o);
                rList.Add(obj);
            }

            return rList;
        }

        #endregion
    }
}

