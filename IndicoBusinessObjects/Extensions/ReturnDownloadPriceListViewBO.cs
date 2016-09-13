using System;
using System.Collections.Generic;
using System.Linq;
//using Indico.BusinessObjects.Util;
using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class ReturnDownloadPriceListViewBO : BusinessObject
    {
        #region Extension Methods
        // Put methods to manipulate Business Objects here. Add, Update etc

        internal static List<Indico.BusinessObjects.ReturnDownloadPriceListViewBO> ToList(IEnumerable<Indico.DAL.ReturnDownloadPriceListView> oQuery)
        {
            List<Indico.DAL.ReturnDownloadPriceListView> oList = oQuery.ToList();
            List<Indico.BusinessObjects.ReturnDownloadPriceListViewBO> rList = new List<Indico.BusinessObjects.ReturnDownloadPriceListViewBO>(oList.Count);
            foreach (Indico.DAL.ReturnDownloadPriceListView o in oList)
            {
                Indico.BusinessObjects.ReturnDownloadPriceListViewBO obj = new Indico.BusinessObjects.ReturnDownloadPriceListViewBO(o);
                rList.Add(obj);
            }

            return rList;
        }

        #endregion
    }
}

