using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace IndicoService.Controllers
{
    public class SortingFieldsController : ApiController
    {
        // GET api/SortingFields
        public List<KeyValuePair<int, string>> Get()
        {
            List<KeyValuePair<int, string>> lstModels = new List<KeyValuePair<int, string>>();
            lstModels.Add(new KeyValuePair<int, string>(0, "Core Range"));
            lstModels.Add(new KeyValuePair<int, string>(1, "Number"));
            lstModels.Add(new KeyValuePair<int, string>(2, "Newest"));

            return lstModels;
        }
    }
}
