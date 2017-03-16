using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace ZohoProxy
{
    
    public class ZohoResponse
    {
        [JsonProperty("response")]
        public ZohoResult Response;
    }

    public class ZohoResult
    {
        [JsonProperty("uri")]
        public string Uri;

        [JsonProperty("error")]
        public ZohoReqeustError Error;

        [JsonProperty("nodata")]
        public ZohoReqeustError Nodata;

        [JsonProperty("result")]
        public JToken Result;

    }
    

}
