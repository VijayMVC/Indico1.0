using System;
using System.Collections.Generic;
using System.Linq;
using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class PriceMarkupLabelBO : BusinessObject
    {
        #region OnPropertyChange Methods
        // Put implementations of OnBusinessObjectNameBOPropertyNameChanging()
        // and OnBusinessObjectNameBOPropertyNameChanged() here

        #endregion

        #region Extension Methods
        // Put methods to manipulate Business Objects here. Add, Update etc

        public static ReturnIntViewBO CloneLabelPriceMarkup(int? existingDistributor, string Label)
        {
            using (IndicoEntities objContext = new IndicoEntities())
            {
                return ReturnIntViewBO.ToList(objContext.CloneLabelPriceMarkup(existingDistributor, Label))[0];
            }
        }

        public static ReturnIntViewBO DeleteLabelPriceMarkup(int? Label)
        {
            using (IndicoEntities objContext = new IndicoEntities())
            {
                return ReturnIntViewBO.ToList(objContext.DeleteLabelPriceMarkup(Label))[0];
            }
        }
        #endregion
    }
}

