using System;
using System.Collections.Generic;
using System.Linq;
using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class JobNameBO : BusinessObject
    {
        #region OnPropertyChange Methods
        // Put implementations of OnBusinessObjectNameBOPropertyNameChanging()
        // and OnBusinessObjectNameBOPropertyNameChanged() here
        
        #endregion
        
        #region Extension Methods
        // Put methods to manipulate Business Objects here. Add, Update etc
        
        public static List<ReturnClientsDetailsViewBO> GetJobNameDetails(string searchtext, int maxrows, int index, int sortcolumn, bool orderby, out int total, string distributor)
        {
            using (IndicoEntities objContext = new IndicoEntities())
            {
                System.Data.Objects.ObjectParameter recCount = new System.Data.Objects.ObjectParameter("P_RecCount", typeof(int));
                List<ReturnClientsDetailsViewBO> lst = ReturnClientsDetailsViewBO.ToList(objContext.GetClientsDetails(searchtext, maxrows, index, sortcolumn, orderby, recCount, distributor));
                total = (int)recCount.Value;

                return lst;
            }
        }

        #endregion
    }
}

