using System;
using System.Collections.Generic;
using System.Linq;
//using Indico.BusinessObjects.Util;
using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class ReturnInvoiceOrderDetailViewBO : BusinessObject
    {        
        #region Extension Methods
        // Put methods to manipulate Business Objects here. Add, Update etc

        internal static List<Indico.BusinessObjects.ReturnInvoiceOrderDetailViewBO> ToList(IEnumerable<Indico.DAL.ReturnInvoiceOrderDetailView> oQuery)
        {
            List<Indico.DAL.ReturnInvoiceOrderDetailView> oList = oQuery.ToList();
            List<Indico.BusinessObjects.ReturnInvoiceOrderDetailViewBO> rList = new List<Indico.BusinessObjects.ReturnInvoiceOrderDetailViewBO>(oList.Count);
            foreach (Indico.DAL.ReturnInvoiceOrderDetailView o in oList)
            {
                Indico.BusinessObjects.ReturnInvoiceOrderDetailViewBO obj = new Indico.BusinessObjects.ReturnInvoiceOrderDetailViewBO(o);
                rList.Add(obj);
            }

            return rList;
        }

        #endregion
    }
}

