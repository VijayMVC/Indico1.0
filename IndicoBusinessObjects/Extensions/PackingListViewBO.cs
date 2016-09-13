using System;
using System.Collections.Generic;
using System.Linq;
//using Indico.BusinessObjects.Util;
using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class PackingListViewBO : BusinessObject
    {        
        #region Extension Methods
        // Put methods to manipulate Business Objects here. Add, Update etc

        internal static List<Indico.BusinessObjects.PackingListViewBO> ToList(IEnumerable<Indico.DAL.PackingListView> oQuery)
        {
            List<Indico.DAL.PackingListView> oList = oQuery.ToList();
            List<Indico.BusinessObjects.PackingListViewBO> rList = new List<Indico.BusinessObjects.PackingListViewBO>(oList.Count);
            foreach (Indico.DAL.PackingListView o in oList)
            {
                Indico.BusinessObjects.PackingListViewBO obj = new Indico.BusinessObjects.PackingListViewBO(o);
                rList.Add(obj);
            }

            return rList;
        }
        #endregion
    }
}

