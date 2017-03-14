using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace ZohoLibrary
{
    public class JsonRPCError
    {
        [JsonProperty("code", Required = Required.Always)]
        public int Code;

        [JsonProperty("message", Required = Required.Always)]
        public string Message;

        [JsonProperty("data")]
        public JToken Data;
        

        public override string ToString()
        {
            return JsonConvert.SerializeObject(this, Newtonsoft.Json.Formatting.Indented);
        }
    }
}
