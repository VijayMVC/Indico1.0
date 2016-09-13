using System;
using System.Collections.Generic;
using System.Linq;
//using Indico.BusinessObjects.Util;
using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class ReturnOrdersClientsBO : BusinessObject
    {        
        #region Extension Methods
        // Put methods to manipulate Business Objects here. Add, Update etc
        internal static List<Indico.BusinessObjects.ReturnOrdersClientsBO> ToList(IEnumerable<Indico.DAL.ReturnOrdersClients> oQuery)
        {
            List<Indico.DAL.ReturnOrdersClients> oList = oQuery.ToList();
            List<Indico.BusinessObjects.ReturnOrdersClientsBO> rList = new List<Indico.BusinessObjects.ReturnOrdersClientsBO>(oList.Count);
            foreach (Indico.DAL.ReturnOrdersClients o in oList)
            {
                Indico.BusinessObjects.ReturnOrdersClientsBO obj = new Indico.BusinessObjects.ReturnOrdersClientsBO(o);
                rList.Add(obj);
            }

            return rList;
        }
        #endregion
    }
}

