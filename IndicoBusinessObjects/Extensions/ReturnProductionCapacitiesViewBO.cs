using System;
using System.Collections.Generic;
using System.Linq;
//using Indico.BusinessObjects.Util;
using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class ReturnProductionCapacitiesViewBO : BusinessObject
    {        
        #region Extension Methods
        // Put methods to manipulate Business Objects here. Add, Update etc

        internal static List<Indico.BusinessObjects.ReturnProductionCapacitiesViewBO> ToList(IEnumerable<Indico.DAL.ReturnProductionCapacitiesView> oQuery)
        {
            List<Indico.DAL.ReturnProductionCapacitiesView> oList = oQuery.ToList();
            List<Indico.BusinessObjects.ReturnProductionCapacitiesViewBO> rList = new List<Indico.BusinessObjects.ReturnProductionCapacitiesViewBO>(oList.Count);
            foreach (Indico.DAL.ReturnProductionCapacitiesView o in oList)
            {
                Indico.BusinessObjects.ReturnProductionCapacitiesViewBO obj = new Indico.BusinessObjects.ReturnProductionCapacitiesViewBO(o);
                rList.Add(obj);
            }

            return rList;
        }

        #endregion
    }
}

