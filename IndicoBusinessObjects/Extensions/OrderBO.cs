using System;
using System.Collections.Generic;
using System.Linq;
using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class OrderBO : BusinessObject
    {
        #region OnPropertyChange Methods
        // Put implementations of OnBusinessObjectNameBOPropertyNameChanging()
        // and OnBusinessObjectNameBOPropertyNameChanged() here

        #endregion

        #region Extension Methods
        // Put methods to manipulate Business Objects here. Add, Update etc

        public static List<ReturnProductionCapacitiesViewBO> Productioncapacities(DateTime? weekEndDate, int itemType = 1)
        {
            using (IndicoEntities objContext = new IndicoEntities())
            {
                List<ReturnProductionCapacitiesView> lst = new List<ReturnProductionCapacitiesView>();
                try
                {
                    lst = objContext.GetProductionCapacities(weekEndDate, itemType).ToList();
                    if (lst[0] == null)
                    {
                        lst[0] = new ReturnProductionCapacitiesView();
                    }
                }
                catch (Exception)
                {
                    lst.Add(new ReturnProductionCapacitiesView());
                }

                return ReturnProductionCapacitiesViewBO.ToList(lst);
            }
        }

        public static List<OrderDetailsViewBO> GetWeeklyFirmOrders(DateTime? weekEndDate, string searchText, string OrderStatus, int sort, bool orderby, int set, int maxRows, out int total, string coordinator, string distributor, string client, int distributorclientaddress)
        {
            using (IndicoEntities objContext = new IndicoEntities())
            {
                System.Data.Objects.ObjectParameter recCount = new System.Data.Objects.ObjectParameter("P_RecCount", typeof(int));
                List<OrderDetailsViewBO> lst = OrderDetailsViewBO.ToList(objContext.GetWeeklyFirmOrders(weekEndDate, searchText, OrderStatus, sort, orderby, set, maxRows, recCount, coordinator, distributor, client, distributorclientaddress));
                total = (int)recCount.Value;

                return lst;
            }
        }

        public static List<OrderDetailsViewBO> GetWeeklySampleOrders(DateTime? weekEndDate, string searchText, string OrderStatus, int sort, bool orderby, int set, int maxRows, out int total, string coordinator, string distributor, string client, int distributorclientaddress)
        {
            using (IndicoEntities objContext = new IndicoEntities())
            {
                System.Data.Objects.ObjectParameter recCount = new System.Data.Objects.ObjectParameter("P_RecCount", typeof(int));
                List<OrderDetailsViewBO> lst = OrderDetailsViewBO.ToList(objContext.GetWeeklySampleOrders(weekEndDate, searchText, OrderStatus, sort, orderby, set, maxRows, recCount, coordinator, distributor, client, distributorclientaddress));
                total = (int)recCount.Value;

                return lst;
            }
        }

        public static List<OrderDetailsViewBO> GetWeeklyReservationOrders(DateTime? weekEndDate, string searchText, string OrderStatus, int sort, bool orderby, int set, int maxRows, out int total, string coordinator, string distributor, string client, int distributorclientaddress)
        {
            using (IndicoEntities objContext = new IndicoEntities())
            {
                System.Data.Objects.ObjectParameter recCount = new System.Data.Objects.ObjectParameter("P_RecCount", typeof(int));
                List<OrderDetailsViewBO> lst = OrderDetailsViewBO.ToList(objContext.GetWeeklyReservationOrders(weekEndDate, searchText, OrderStatus, sort, orderby, set, maxRows, recCount, coordinator, distributor, client, distributorclientaddress));
                total = (int)recCount.Value;

                return lst;
            }
        }

        public static List<OrderDetailsViewBO> GetWeeklyJacketOrders(DateTime? weekEndDate, string searchText, string OrderStatus, int sort, bool orderby, int set, int maxRows, out int total, string coordinator, string distributor, string client, int distributorclientaddress)
        {
            using (IndicoEntities objContext = new IndicoEntities())
            {
                System.Data.Objects.ObjectParameter recCount = new System.Data.Objects.ObjectParameter("P_RecCount", typeof(int));
                List<OrderDetailsViewBO> lst = OrderDetailsViewBO.ToList(objContext.GetWeeklyJacketOrders(weekEndDate, searchText, OrderStatus, sort, orderby, set, maxRows, recCount, coordinator, distributor, client, distributorclientaddress));
                total = (int)recCount.Value;

                return lst;
            }
        }

        public static List<OrderDetailsViewBO> GetWeeklyLessFiveItemOrders(DateTime? weekEndDate, string searchText, string OrderStatus, int sort, bool orderby, int set, int maxRows, out int total, string coordinator, string distributor, string client, int distributorclientaddress)
        {
            using (IndicoEntities objContext = new IndicoEntities())
            {
                System.Data.Objects.ObjectParameter recCount = new System.Data.Objects.ObjectParameter("P_RecCount", typeof(int));
                List<OrderDetailsViewBO> lst = OrderDetailsViewBO.ToList(objContext.GetWeeklyLessFiveItemOrders(weekEndDate, searchText, OrderStatus, sort, orderby, set, maxRows, recCount, coordinator, distributor, client, distributorclientaddress));
                total = (int)recCount.Value;

                return lst;
            }
        }

        public static List<OrderDetailsViewBO> GetWeeklyHoldOrders(DateTime? weekEndDate, string searchText, string OrderStatus, string coordinator, string distributor, string client, int distributorclientaddress)
        {
            using (IndicoEntities objContext = new IndicoEntities())
            {
                // System.Data.Objects.ObjectParameter recCount = new System.Data.Objects.ObjectParameter("P_RecCount", typeof(int));
                List<OrderDetailsViewBO> lst = OrderDetailsViewBO.ToList(objContext.GetWeeklyHoldOrders(weekEndDate, searchText, OrderStatus, coordinator, distributor, client, distributorclientaddress));
                //total = (int)recCount.Value;

                return lst;
            }
        }

        public static ReturnIntViewBO DeleteOrder(int? orderid)
        {
            using (IndicoEntities objContext = new IndicoEntities())
            {
                return ReturnIntViewBO.ToList(objContext.DeleteOrder(orderid))[0];
            }
        }

        public static List<ReturnOrderDetailsIndicoPriceViewBO> GetOrderDetails(int? Orderid, int? priceterm)
        {
            using (IndicoEntities objContext = new IndicoEntities())
            {
                return ReturnOrderDetailsIndicoPriceViewBO.ToList(objContext.GetOrderDetailIndicoPrice(Orderid, priceterm));
            }
        }

        public static List<OrderDetailsViewBO> GetOrders(string searchText, int LogcompanyID, string status, int coordinator, int distributor, int client, DateTime? selecteddate1, DateTime? selecteddate2, int distributorclientaddress)
        {
            using (IndicoEntities objContext = new IndicoEntities())
            {
                System.Data.Objects.ObjectParameter recCount = new System.Data.Objects.ObjectParameter("P_RecCount", typeof(int));
                List<OrderDetailsViewBO> lst = OrderDetailsViewBO.ToList(objContext.ViewOrderDetails(searchText, LogcompanyID, status, coordinator, distributor, client, selecteddate1, selecteddate2, distributorclientaddress));

                return lst;
            }
        }

        public static List<ReturnShiipingDetailsViewBO> GetShippingDetails(DateTime? WeekendDate)
        {
            using (IndicoEntities objContext = new IndicoEntities())
            {

                List<ReturnShiipingDetailsViewBO> lst = ReturnShiipingDetailsViewBO.ToList(objContext.GetShippingDetails(WeekendDate));


                return lst;
            }
        }

        public static List<ReturnOrderQuantitiesAndAmountBO> GetOrderQuantitiesAndAmountForDistributorsForGivenDateRange(DateTime? startDate, DateTime? endDate, string distributorName, int distributorId)
        {
            using (IndicoEntities objContext = new IndicoEntities())
            {
                List<ReturnOrderQuantitiesAndAmountBO> lst = new List<ReturnOrderQuantitiesAndAmountBO>(); //**** SDSReturnOrderQuantitiesAndAmountBO.ToList(objContext.GetOrderQuantitiesAndAmountForDistributorsForGivenDateRange(startDate, endDate, distributorName, distributorId));

                return lst;
            }
        }

        public static List<ReturnDetailReportByDistributorBO> GetDetailReportForDistributorForGivenDateRange(DateTime? startDate, DateTime? endDate, int distributorId)
        {
            using (IndicoEntities objContext = new IndicoEntities())
            {
                List<ReturnDetailReportByDistributorBO> lst = new List<ReturnDetailReportByDistributorBO>(); //**** SDS ReturnDetailReportContentBO.ToList(objContext.GetDetailReportForDistributorForGivenDateRange(startDate, endDate, distributorId));

                return lst;
            }
        }

        #endregion
    }

    public static class OrderExtensions
    {
        public static void BindList(this System.Web.UI.WebControls.ListControl list, IEnumerable<ReturnOrdersCoordinatorsBO> vlcts, string valueField, string textField)
        {
            list.DataSource = vlcts;
            list.DataValueField = valueField;
            list.DataTextField = textField;
            list.DataBind();

            list.Items.Insert(0, new System.Web.UI.WebControls.ListItem("All", "0"));
        }

        public static void BindList(this System.Web.UI.WebControls.ListControl list, IEnumerable<ReturnOrdersDistributorsBO> vlcts, string valueField, string textField)
        {
            list.DataSource = vlcts;
            list.DataValueField = valueField;
            list.DataTextField = textField;
            list.DataBind();

            list.Items.Insert(0, new System.Web.UI.WebControls.ListItem("All", "0"));
        }

        public static void BindList(this System.Web.UI.WebControls.ListControl list, IEnumerable<ReturnOrdersClientsBO> vlcts, string valueField, string textField)
        {
            list.DataSource = vlcts;
            list.DataValueField = valueField;
            list.DataTextField = textField;
            list.DataBind();

            list.Items.Insert(0, new System.Web.UI.WebControls.ListItem("All", "0"));
        }

        public static void BindList(this System.Web.UI.WebControls.ListControl list, IEnumerable<ReturnOrdersShipmentAddressViewBO> vlcts, string valueField, string textField)
        {
            list.DataSource = vlcts;
            list.DataValueField = valueField;
            list.DataTextField = textField;
            list.DataBind();

            list.Items.Insert(0, new System.Web.UI.WebControls.ListItem("All", "0"));
        }
    }
}

