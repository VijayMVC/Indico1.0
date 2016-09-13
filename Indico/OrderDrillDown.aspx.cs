using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using Dapper;
using Indico.Common;
using Indico.Models;
using Telerik.Web.UI;

namespace Indico
{
    

    public partial class OrderDrillDown : IndicoPage
    {
        #region Enums

        public enum OrderDrillDownType
        {
            Firm = 2,
            Reservations = 3,
            Hold = 4,
            All = 5,
            Outerware = 1,
            UptoFive = 6,
            Sample = 7,
            
        }

        #endregion

        #region Fields

        private DateTime _weekEndDate;
        private OrderDrillDownType _type;

        #endregion

        #region Methods

        private bool LoadProperties()
        {
            try
            {
                
                var weekEndDate = Request.QueryString["WeekendDate"];
                if (weekEndDate != null)
                    _weekEndDate = DateTime.Parse(weekEndDate);
                else
                    return false;

                var type = Request.QueryString["Type"];
                if (type != null)
                {
                    var str = type.ToUpper();
                    switch (str)
                    {
                        case "FIRM":
                            _type = OrderDrillDownType.Firm;
                            break;
                        case "HOLD":
                            _type = OrderDrillDownType.Hold;
                            break;
                        case "RESERVATIONS":
                            _type = OrderDrillDownType.Reservations;
                            break;
                        default:
                            return false;
                    }
                }
                
            }
            catch (Exception)
            {

                return false;
            }
            return true;
        }

        private void PopulateOrderGrid()
        {
            using (
                var connection =
                    new SqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString))
            {
                var spname = "";
                switch (_type)
                {
                    case OrderDrillDownType.Firm:
                        spname = "GetFirmOrdersForGivenWeekForPieces";
                        break;
                    case OrderDrillDownType.Reservations:
                        spname = "GetReservationsForGivenWeekForPieces";
                        break;
                    case OrderDrillDownType.Hold:
                        spname = "GetHoldItemsForGivenWeekForPieces";
                        break;
                }
                var data= connection.Query<OrderDrillDownMedel>(string.Format("EXEC [dbo].[SPC_{0}] '{1}'",
                        spname, _weekEndDate.ToString("yyyyMMdd"))).ToList();
                if (data.Count < 1)
                {
                    dvEmptyContent.Visible = true;
                    return;
                }

                OrderGrid.DataSource = data;
                OrderGrid.DataBind();
                dvDataContent.Visible = true;
            }
        }

        private void PopulateControls()
        {
            litHeaderText.Text = ActivePage.Heading;
        }

        #endregion

        #region Events

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!LoadProperties())
                throw new Exception("Given Query Parameter Values Are Wrong For OrderDrillDown");
            PopulateOrderGrid();
            PopulateControls();
        }

        protected void OnOrderGridItemDataBound(object sender, GridItemEventArgs e)
        {
           // throw new NotImplementedException();
        }

        #endregion


    }
}