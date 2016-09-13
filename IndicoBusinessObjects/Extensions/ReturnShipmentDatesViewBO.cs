using System;
using System.Collections.Generic;
using System.Linq;
//using Indico.BusinessObjects.Util;
using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class ReturnShipmentDatesViewBO : BusinessObject
    {        
        #region Extension Methods
        // Put methods to manipulate Business Objects here. Add, Update etc

        internal static List<Indico.BusinessObjects.ReturnShipmentDatesViewBO> ToList(IEnumerable<Indico.DAL.ReturnShipmentDatesView> oQuery)
        {
            List<Indico.DAL.ReturnShipmentDatesView> oList = oQuery.ToList();
            List<Indico.BusinessObjects.ReturnShipmentDatesViewBO> rList = new List<Indico.BusinessObjects.ReturnShipmentDatesViewBO>(oList.Count);
            foreach (Indico.DAL.ReturnShipmentDatesView o in oList)
            {
                Indico.BusinessObjects.ReturnShipmentDatesViewBO obj = new Indico.BusinessObjects.ReturnShipmentDatesViewBO(o);
                rList.Add(obj);
            }

            return rList;
        }

        #endregion
    }
}

