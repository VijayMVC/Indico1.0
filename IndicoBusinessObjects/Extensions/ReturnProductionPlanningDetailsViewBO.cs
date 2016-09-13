using System;
using System.Collections.Generic;
using System.Linq;
//using Indico.BusinessObjects.Util;
using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class ReturnProductionPlanningDetailsViewBO : BusinessObject
    {        
        #region Extension Methods
        // Put methods to manipulate Business Objects here. Add, Update etc

        internal static List<Indico.BusinessObjects.ReturnProductionPlanningDetailsViewBO> ToList(IEnumerable<Indico.DAL.ReturnProductionPlanningDetailsView> oQuery)
        {
            List<Indico.DAL.ReturnProductionPlanningDetailsView> oList = oQuery.ToList();
            List<Indico.BusinessObjects.ReturnProductionPlanningDetailsViewBO> rList = new List<Indico.BusinessObjects.ReturnProductionPlanningDetailsViewBO>(oList.Count);
            foreach (Indico.DAL.ReturnProductionPlanningDetailsView o in oList)
            {
                Indico.BusinessObjects.ReturnProductionPlanningDetailsViewBO obj = new Indico.BusinessObjects.ReturnProductionPlanningDetailsViewBO(o);
                rList.Add(obj);
            }

            return rList;
        }

        #endregion
    }
}

