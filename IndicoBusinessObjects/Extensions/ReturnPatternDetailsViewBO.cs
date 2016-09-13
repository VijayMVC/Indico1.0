using System;
using System.Collections.Generic;
using System.Linq;
//using Indico.BusinessObjects.Util;
using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class ReturnPatternDetailsViewBO : BusinessObject
    {        
        #region Extension Methods
        // Put methods to manipulate Business Objects here. Add, Update etc

        internal static List<Indico.BusinessObjects.ReturnPatternDetailsViewBO> ToList(IEnumerable<Indico.DAL.ReturnPatternDetailsView> oQuery)
        {
            List<Indico.DAL.ReturnPatternDetailsView> oList = oQuery.ToList();
            List<Indico.BusinessObjects.ReturnPatternDetailsViewBO> rList = new List<Indico.BusinessObjects.ReturnPatternDetailsViewBO>(oList.Count);
            foreach (Indico.DAL.ReturnPatternDetailsView o in oList)
            {
                Indico.BusinessObjects.ReturnPatternDetailsViewBO obj = new Indico.BusinessObjects.ReturnPatternDetailsViewBO(o);
                rList.Add(obj);
            }

            return rList;
        }

        #endregion
    }
}

