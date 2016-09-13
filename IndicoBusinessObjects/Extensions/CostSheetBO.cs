using System;
using System.Collections.Generic;
using System.Linq;
using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class CostSheetBO : BusinessObject
    {
        #region OnPropertyChange Methods
        // Put implementations of OnBusinessObjectNameBOPropertyNameChanging()
        // and OnBusinessObjectNameBOPropertyNameChanged() here
        
        #endregion
        
        #region Extension Methods
        // Put methods to manipulate Business Objects here. Add, Update etc

        public static ReturnIntViewBO UpdateDutyRateExchnageRate(decimal dutyrate, decimal exchnagerate)
        {
            using (IndicoEntities objContext = new IndicoEntities())
            {
                return ReturnIntViewBO.ToList(objContext.UpdateDutyRateExchnageRateCostSheet(dutyrate, exchnagerate))[0];
            }
        }

        public static List<CostSheetDetailsViewBO> GetCostSheetDetails(string searchText)
        {
            using (IndicoEntities objContext = new IndicoEntities())
            {
                List<CostSheetDetailsViewBO> lst = CostSheetDetailsViewBO.ToList(objContext.GetCostSheetDetails(searchText));

                return lst;
            }
        }

        #endregion
    }
}

