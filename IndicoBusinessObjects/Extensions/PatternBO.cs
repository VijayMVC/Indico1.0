using System;
using System.Collections.Generic;
using System.Linq;
using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class PatternBO : BusinessObject
    {
        #region OnPropertyChange Methods
        // Put implementations of OnBusinessObjectNameBOPropertyNameChanging()
        // and OnBusinessObjectNameBOPropertyNameChanged() here

        #endregion

        #region Extension Methods
        // Put methods to manipulate Business Objects here. Add, Update etc

        public static List<ReturnPatternDetailsViewBO> GetPatternDetails(string searchtext, int? maxrows, int? index, int? sortcolumn, bool? orderby, out int total, int blackchrome, string specstatus, int pattenstatus)
        {
            using (IndicoEntities objContext = new IndicoEntities())
            {
                System.Data.Objects.ObjectParameter recCount = new System.Data.Objects.ObjectParameter("P_RecCount", typeof(int));
                List<ReturnPatternDetailsViewBO> lst = ReturnPatternDetailsViewBO.ToList(objContext.GetPatternDetails(searchtext, maxrows, index, sortcolumn, orderby, recCount, blackchrome, specstatus, pattenstatus));
                total = (int)recCount.Value;

                return lst;
            }
        }

        #endregion
    }
}

