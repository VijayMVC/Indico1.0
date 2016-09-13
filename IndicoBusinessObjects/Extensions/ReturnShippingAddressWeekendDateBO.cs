using System;
using System.Collections.Generic;
using System.Linq;
//using Indico.BusinessObjects.Util;
using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class ReturnShippingAddressWeekendDateBO : BusinessObject
    {        
        #region Extension Methods
        // Put methods to manipulate Business Objects here. Add, Update etc

        internal static List<Indico.BusinessObjects.ReturnShippingAddressWeekendDateBO> ToList(IEnumerable<Indico.DAL.ReturnShippingAddressWeekendDate> oQuery)
        {
            List<Indico.DAL.ReturnShippingAddressWeekendDate> oList = oQuery.ToList();
            List<Indico.BusinessObjects.ReturnShippingAddressWeekendDateBO> rList = new List<Indico.BusinessObjects.ReturnShippingAddressWeekendDateBO>(oList.Count);
            foreach (Indico.DAL.ReturnShippingAddressWeekendDate o in oList)
            {
                Indico.BusinessObjects.ReturnShippingAddressWeekendDateBO obj = new Indico.BusinessObjects.ReturnShippingAddressWeekendDateBO(o);
                rList.Add(obj);
            }

            return rList;
        }

        #endregion
    }
}

