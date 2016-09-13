using System;
using System.Collections.Generic;
using System.Linq;
using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class PriceLevelCostBO : BusinessObject
    {
        #region OnPropertyChange Methods
        // Put implementations of OnBusinessObjectNameBOPropertyNameChanging()
        // and OnBusinessObjectNameBOPropertyNameChanged() here
        
        #endregion
        
        #region Extension Methods
        // Put methods to manipulate Business Objects here. Add, Update etc

        public static List<ReturnIndimanPriceListDataViewBO> GeIndimanPriceListData(int distributor)
        {
            using (IndicoEntities objContext = new IndicoEntities())
            {
                System.Data.Objects.ObjectParameter recCount = new System.Data.Objects.ObjectParameter("P_RecCount", typeof(int));
                List<ReturnIndimanPriceListDataViewBO> lst = ReturnIndimanPriceListDataViewBO.ToList(objContext.GetIndimanPriceListData(distributor));               

                return lst;
            }
        }
        #endregion
    }
}

