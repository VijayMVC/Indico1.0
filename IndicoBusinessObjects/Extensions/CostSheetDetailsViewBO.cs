using System;
using System.Collections.Generic;
using System.Linq;
//using Indico.BusinessObjects.Util;
using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class CostSheetDetailsViewBO : BusinessObject
    {        
        #region Extension Methods
        // Put methods to manipulate Business Objects here. Add, Update etc

        internal static List<Indico.BusinessObjects.CostSheetDetailsViewBO> ToList(IEnumerable<Indico.DAL.CostSheetDetailsView> oQuery)
        {
            List<Indico.DAL.CostSheetDetailsView> oList = oQuery.ToList();
            List<Indico.BusinessObjects.CostSheetDetailsViewBO> rList = new List<Indico.BusinessObjects.CostSheetDetailsViewBO>(oList.Count);
            foreach (Indico.DAL.CostSheetDetailsView o in oList)
            {
                Indico.BusinessObjects.CostSheetDetailsViewBO obj = new Indico.BusinessObjects.CostSheetDetailsViewBO(o);
                rList.Add(obj);
            }

            return rList;
        }

        #endregion
    }
}

