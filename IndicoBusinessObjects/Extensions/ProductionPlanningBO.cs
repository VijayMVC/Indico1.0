using System;
using System.Collections.Generic;
using System.Linq;
using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class ProductionPlanningBO : BusinessObject
    {
        #region OnPropertyChange Methods
        // Put implementations of OnBusinessObjectNameBOPropertyNameChanging()
        // and OnBusinessObjectNameBOPropertyNameChanged() here

        #endregion

        #region Extension Methods
        // Put methods to manipulate Business Objects here. Add, Update etc\

        //public static List<ReturnProductionPlanningDetailsViewBO> GetProductionPlans(int Week, int Year)
        //{
        //    using (IndicoEntities objContext = new IndicoEntities())
        //    {
        //        List<ReturnProductionPlanningDetailsViewBO> lst = new List<ReturnProductionPlanningDetailsViewBO>(); // ReturnProductionPlanningDetailsViewBO.ToList(objContext.GetProductionPlanningDetails(Week, Year));

        //        return lst;
        //    }
        //}

        //public static ReturnIntViewBO UpdateProductionPlan(int? weeklyProductionCapacity, int? orderDetail, int? productionLine, DateTime? sewingDate)
        //{
        //    using (IndicoEntities objContext = new IndicoEntities())
        //    {
        //        return new ReturnIntViewBO(); //.ToList(objContext.UpdateProductionPlanning(weeklyProductionCapacity, orderDetail, productionLine, sewingDate))[0];
        //    }
        //}

        #endregion
    }
}

