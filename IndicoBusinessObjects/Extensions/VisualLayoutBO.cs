using System;
using System.Collections.Generic;
using System.Linq;
using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class VisualLayoutBO : BusinessObject
    {
        #region OnPropertyChange Methods
        // Put implementations of OnBusinessObjectNameBOPropertyNameChanging()
        // and OnBusinessObjectNameBOPropertyNameChanged() here

        #endregion

        #region Extension Methods
        // Put methods to manipulate Business Objects here. Add, Update etc

        public static List<ReturnVisualLayoutDetailsViewBO> GetVisualLayoutDetails(string searchtext, int? maxrows, int? index, int? sortcolumn, bool? orderby, out int total, string coordinator, string distributor, string client, int commonproduct)
        {
            using (IndicoEntities objContext = new IndicoEntities())
            {
                System.Data.Objects.ObjectParameter recCount = new System.Data.Objects.ObjectParameter("P_RecCount", typeof(int));
                List<ReturnVisualLayoutDetailsViewBO> lst = ReturnVisualLayoutDetailsViewBO.ToList(objContext.GetVisualLayoutDetails(searchtext, maxrows, index, sortcolumn, orderby, recCount, coordinator, distributor, client, commonproduct));
                total = (int)recCount.Value;

                return lst;
            }
        }

        #endregion
    }
    public static class VisualLayoutExtensions
    {
        public static void BindList(this System.Web.UI.WebControls.ListControl list, IEnumerable<VisualLayoutClientsBO> vlcts, string valueField, string textField)
        {
            list.DataSource = vlcts;
            list.DataValueField = valueField;
            list.DataTextField = textField;
            list.DataBind();

            list.Items.Insert(0, new System.Web.UI.WebControls.ListItem("All", "0"));
        }

        public static void BindList(this System.Web.UI.WebControls.ListControl list, IEnumerable<VisualLayoutDistributorsBO> vlds, string valueField, string textField)
        {
            list.DataSource = vlds;
            list.DataValueField = valueField;
            list.DataTextField = textField;
            list.DataBind();

            list.Items.Insert(0, new System.Web.UI.WebControls.ListItem("All", "0"));
        }

        public static void BindList(this System.Web.UI.WebControls.ListControl list, IEnumerable<VisualLayoutCoordinatorsBO> vlcs, string valueField, string textField)
        {
            list.DataSource = vlcs;
            list.DataValueField = valueField;
            list.DataTextField = textField;
            list.DataBind();

            list.Items.Insert(0, new System.Web.UI.WebControls.ListItem("All", "0"));
        }
    }
}

