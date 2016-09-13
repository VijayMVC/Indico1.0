using System;
using System.Collections.Generic;
using System.Linq;
using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class DistributorPriceMarkupBO : BusinessObject
    {
        #region OnPropertyChange Methods
        // Put implementations of OnBusinessObjectNameBOPropertyNameChanging()
        // and OnBusinessObjectNameBOPropertyNameChanged() here

        #endregion

        #region Extension Methods
        // Put methods to manipulate Business Objects here. Add, Update etc

        public static ReturnIntViewBO CloneDistributorPriceMarkup(int? existingDistributor, int? newDitributor)
        {
            using (IndicoEntities objContext = new IndicoEntities())
            {
                return ReturnIntViewBO.ToList(objContext.CloneDistributorPriceMarkup(existingDistributor, newDitributor))[0];
            }
        }

        public static ReturnIntViewBO DeleteDistributorPriceMarkup(int? distributor)
        {
            using (IndicoEntities objContext = new IndicoEntities())
            {
                return ReturnIntViewBO.ToList(objContext.DeleteDistributorPriceMarkup(distributor))[0];
            }
        }

        #endregion
    }

    public static class DistributorPriceMarkupExtentions
    {
        public static void BindList(this System.Web.UI.WebControls.ListControl list, IEnumerable<GetNonAssignedPriceMarkupDistributorsViewBO> lstgnapmd, string valueField, string textField)
        {
            list.DataSource = lstgnapmd;
            list.DataValueField = valueField;
            list.DataTextField = textField;
            list.DataBind();
            
            /*list.Items.Insert(0, new System.Web.UI.WebControls.ListItem(vlcts[1]., "0"));*/
        }

        public static void BindListClone(this System.Web.UI.WebControls.ListControl list, IEnumerable<GetNonAssignedPriceMarkupDistributorsViewBO> lstgnapmd, string valueField, string textField)
        {
            list.DataSource = lstgnapmd;
            list.DataValueField = valueField;
            list.DataTextField = textField;
            list.DataBind();

            list.Items.Insert(0, new System.Web.UI.WebControls.ListItem("Select your new distributor", "0"));
        }
    }
}

