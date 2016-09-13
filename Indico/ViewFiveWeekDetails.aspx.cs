using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using Dapper;
using Indico.Common;
using Indico.Models;
namespace Indico
{
    public partial class ViewFiveWeekDetails : IndicoPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            PopulateCharts();
        }


        private void PopulateCharts()
        {
            PopulatePoloChart();
            PopulateOuterwareChart();
        }

        private void PopulatePoloChart()
        {
            using (var connection = new SqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString))
            {
                connection.Open();
                var data = connection.Query<FiveWeekDetailsModel>("EXEC [dbo].[SPC_GetFiveWeekDetails] 1").ToList();
                connection.Close();
                if (data.Count < 1)
                    return;
                PoloChart.DataSource = data;
                PoloChart.DataBind();
            }
        }

        private void PopulateOuterwareChart()
        {

            using (var connection = new SqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString))
            {
                connection.Open();
                var data = connection.Query<FiveWeekDetailsModel>("EXEC [dbo].[SPC_GetFiveWeekDetails] 2").ToList();
                connection.Close();
                if (data.Count < 1)
                    return;
                OuterwareChart.DataSource = data;
                OuterwareChart.DataBind();
            }
        }
    }
}