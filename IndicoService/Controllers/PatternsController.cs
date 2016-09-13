using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using Indico.BusinessObjects;
using IndicoService.Models;
using System.IO;
using System.Xml.Serialization;
using System.Text;
using Dapper;
using System.Configuration;
using System.Data.SqlClient;
using System.Data;

namespace IndicoService.Controllers
{
    public class PatternsController : ApiController
    {
        // GET api/Patterns
        public ReturnPatternList Get(string searchText, string category, int? pageSize = 10, int? set = 1, int? sort = 0, int? coreCat = 0)
        {
            ReturnPatternList result = new ReturnPatternList();

            try
            {   
                List<PatternModel> lstPatterns = new List<PatternModel>();

                SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString);
                connection.Open();

                var p = new DynamicParameters();
                p.Add("@P_SearchText", string.IsNullOrEmpty(searchText) ? "" : searchText);
                p.Add("@P_MaxRows", pageSize);
                p.Add("@P_Set", set);
                p.Add("@P_Sort", sort);
                p.Add("@P_CoreCategory", coreCat);
                p.Add("@P_Category", string.IsNullOrEmpty(category) ? "" : category);
                p.Add("@P_RecCount", dbType: DbType.Int32, direction: ParameterDirection.Output);

                lstPatterns = connection.Query<PatternModel>("SPC_GetPatternDetails", p, commandType: CommandType.StoredProcedure).ToList();
                result.TotalCount = p.Get<int>("@P_RecCount");

                connection.Close();

                foreach (PatternModel model in lstPatterns)
                {
                    string imgLocation = IndicoConfiguration.AppConfiguration.DataFolderName + "/noimage-png-350px-350px.png";

                    if (!string.IsNullOrEmpty(model.FileName))
                    {
                        if (File.Exists(IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\PatternTemplates\\" + model.Pattern.ToString() + "\\" + model.FileName)) //IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + imgPath))
                        {
                            imgLocation = IndicoConfiguration.AppConfiguration.DataFolderName + "/PatternTemplates/" + model.Pattern.ToString() + "/" + model.FileName;
                        }
                    }

                    model.FileName = IndicoConfiguration.AppConfiguration.SiteHostAddress + imgLocation;
                }

                result.PatternList = lstPatterns;
            }
            catch (Exception ex)
            {
                result.Error = ex.ToString();
            }

            return result;
        }

        public class ReturnPatternList
        {
            public List<PatternModel> PatternList = new List<PatternModel>();
            public int TotalCount = 0;
            public string Error = string.Empty;
        }
    }
}
