using System;
using System.Collections.Generic;
using System.Linq;
using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class PriceListDownloadsBO : BusinessObject
    {
        #region OnPropertyChange Methods
        // Put implementations of OnBusinessObjectNameBOPropertyNameChanging()
        // and OnBusinessObjectNameBOPropertyNameChanged() here

        #endregion

        #region Extension Methods
        // Put methods to manipulate Business Objects here. Add, Update etc

        public static List<ReturnDownloadPriceListViewBO> ReturnDownloadPriceList(int? Type)
        {
            using (IndicoEntities objContext = new IndicoEntities())
            {
                return ReturnDownloadPriceListViewBO.ToList(objContext.GetDownloadPriceList(Type));
            }
        }
        #endregion
    }
}

