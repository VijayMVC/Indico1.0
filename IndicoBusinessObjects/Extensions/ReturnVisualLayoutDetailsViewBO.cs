using System;
using System.Collections.Generic;
using System.Linq;
//using Indico.BusinessObjects.Util;
using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class ReturnVisualLayoutDetailsViewBO : BusinessObject
    {        
        #region Extension Methods
        // Put methods to manipulate Business Objects here. Add, Update etc

        internal static List<Indico.BusinessObjects.ReturnVisualLayoutDetailsViewBO> ToList(IEnumerable<Indico.DAL.ReturnVisualLayoutDetailsView> oQuery)
        {
            List<Indico.DAL.ReturnVisualLayoutDetailsView> oList = oQuery.ToList();
            List<Indico.BusinessObjects.ReturnVisualLayoutDetailsViewBO> rList = new List<Indico.BusinessObjects.ReturnVisualLayoutDetailsViewBO>(oList.Count);
            foreach (Indico.DAL.ReturnVisualLayoutDetailsView o in oList)
            {
                Indico.BusinessObjects.ReturnVisualLayoutDetailsViewBO obj = new Indico.BusinessObjects.ReturnVisualLayoutDetailsViewBO(o);
                rList.Add(obj);
            }

            return rList;
        }

        #endregion
    }
}

