using System;
using System.Collections.Generic;
using System.Linq;
using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class ClientBO : BusinessObject
    {
        #region OnPropertyChange Methods
        // Put implementations of OnBusinessObjectNameBOPropertyNameChanging()
        // and OnBusinessObjectNameBOPropertyNameChanged() here

        #endregion

        #region Extension Methods
        // Put methods to manipulate Business Objects here. Add, Update etc

        public static List<ReturnOrdersClientsBO> GetDistriburorClients(int distributor)
        {
            using (IndicoEntities objContext = new IndicoEntities())
            {

                List<ReturnOrdersClientsBO> lst = ReturnOrdersClientsBO.ToList(objContext.GetOrderClients(distributor));               

                return lst;
            }
        }

        #endregion
    }
}

