using System;
using System.Collections.Generic;
using System.Linq;
//using Indico.BusinessObjects.Util;
using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class ReturnWeeklyAddressDetailsBO : BusinessObject
    {        
        #region Extension Methods
        // Put methods to manipulate Business Objects here. Add, Update etc

        internal static List<Indico.BusinessObjects.ReturnWeeklyAddressDetailsBO> ToList(IEnumerable<Indico.DAL.ReturnWeeklyAddressDetails> oQuery)
        {
            List<Indico.DAL.ReturnWeeklyAddressDetails> oList = oQuery.ToList();
            List<Indico.BusinessObjects.ReturnWeeklyAddressDetailsBO> rList = new List<Indico.BusinessObjects.ReturnWeeklyAddressDetailsBO>(oList.Count);
            foreach (Indico.DAL.ReturnWeeklyAddressDetails o in oList)
            {
                Indico.BusinessObjects.ReturnWeeklyAddressDetailsBO obj = new Indico.BusinessObjects.ReturnWeeklyAddressDetailsBO(o);
                rList.Add(obj);
            }

            return rList;
        }
        #endregion
    }
}

