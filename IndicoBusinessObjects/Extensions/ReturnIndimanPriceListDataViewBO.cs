using System;
using System.Collections.Generic;
using System.Linq;
//using Indico.BusinessObjects.Util;
using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class ReturnIndimanPriceListDataViewBO : BusinessObject
    {        
        #region Extension Methods
        // Put methods to manipulate Business Objects here. Add, Update etc

        internal static List<Indico.BusinessObjects.ReturnIndimanPriceListDataViewBO> ToList(IEnumerable<Indico.DAL.ReturnIndimanPriceListDataView> oQuery)
        {
            List<Indico.DAL.ReturnIndimanPriceListDataView> oList = oQuery.ToList();
            List<Indico.BusinessObjects.ReturnIndimanPriceListDataViewBO> rList = new List<Indico.BusinessObjects.ReturnIndimanPriceListDataViewBO>(oList.Count);
            foreach (Indico.DAL.ReturnIndimanPriceListDataView o in oList)
            {
                Indico.BusinessObjects.ReturnIndimanPriceListDataViewBO obj = new Indico.BusinessObjects.ReturnIndimanPriceListDataViewBO(o);
                rList.Add(obj);
            }

            return rList;
        }
        #endregion
    }
}

