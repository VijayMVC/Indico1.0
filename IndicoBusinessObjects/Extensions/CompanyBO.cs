using System;
using System.Collections.Generic;
using System.Linq;
using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class CompanyBO : BusinessObject
    {
        #region OnPropertyChange Methods
        // Put implementations of OnBusinessObjectNameBOPropertyNameChanging()
        // and OnBusinessObjectNameBOPropertyNameChanged() here

        #endregion

        #region Extension Methods
        // Put methods to manipulate Business Objects here. Add, Update etc

        public static List<ReturnDistributorDetailsViewBO> GetDistributorDetails(string searchtext, int? maxrows, int? index, int? sortcolumn, bool? orderby, out int total, string pcoordinator, string scoordinator)
        {
            using (IndicoEntities objContext = new IndicoEntities())
            {
                System.Data.Objects.ObjectParameter recCount = new System.Data.Objects.ObjectParameter("P_RecCount", typeof(int));
                List<ReturnDistributorDetailsViewBO> lst = ReturnDistributorDetailsViewBO.ToList(objContext.GetDistributorsDetails(searchtext, maxrows, index, sortcolumn, orderby, recCount, pcoordinator, scoordinator));
                total = (int)recCount.Value;

                return lst;
            }
        }

        #endregion
    }
    public static class CompanyExtensions
    {
        public static void BindList(this System.Web.UI.WebControls.ListControl list, IEnumerable<ReturnDistributorPrimaryCoordinatorBO> vlcts, string valueField, string textField)
        {
            list.DataSource = vlcts;
            list.DataValueField = valueField;
            list.DataTextField = textField;
            list.DataBind();

            list.Items.Insert(0, new System.Web.UI.WebControls.ListItem("All", "0"));
        }

        public static void BindList(this System.Web.UI.WebControls.ListControl list, IEnumerable<ReturnDistributorSecondaryCoordinatorBO> vlcts, string valueField, string textField)
        {
            list.DataSource = vlcts;
            list.DataValueField = valueField;
            list.DataTextField = textField;
            list.DataBind();

            list.Items.Insert(0, new System.Web.UI.WebControls.ListItem("All", "0"));
        }

        public static bool IsIndicoAdelade(CompanyBO objCompany)
        {
            return (objCompany.Name.ToUpper() == "INDICO");
        }
    }
}

