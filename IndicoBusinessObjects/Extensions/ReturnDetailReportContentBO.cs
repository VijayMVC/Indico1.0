using System;
using System.Collections.Generic;
using System.Linq;
using Indico.BusinessObjects;
using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class ReturnDetailReportContentBO : BusinessObject
    {        
        #region Extension Methods
        // Put methods to manipulate Business Objects here. Add, Update etc

        internal static List<ReturnDetailReportContentBO> ToList(IEnumerable<ReturnDetailReportContent> oQuery)
        {
            List<ReturnDetailReportContent> oList = oQuery.ToList();
            List<ReturnDetailReportContentBO> rList = new List<ReturnDetailReportContentBO>(oList.Count);
            foreach (ReturnDetailReportContent o in oList)
            {
                ReturnDetailReportContentBO obj = new ReturnDetailReportContentBO(o);
                rList.Add(obj);
            }

            return rList;
        }

        #endregion
    }
}

