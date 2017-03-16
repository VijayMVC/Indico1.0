using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace ZohoLibrary
{
    public class JsonRPCRequest
    {
        public JsonRPCRequest(string id, string method)
            : this(id, method, null)
        {
        }

        public JsonRPCRequest(string id, string method, JToken parameters)
        {
            this.Id = id;
            this.Method = method;
            this.Parameters = parameters;
        }

        [JsonProperty("jsonrpc", Required = Required.Always)]
        public string JsonRPC { get { return "2.0"; } }

        [JsonProperty("id", Required = Required.Always)]
        public string Id { get; private set; }

        [JsonProperty("method", Required = Required.Always)]
        public string Method { get; private set; }

        [JsonProperty("params")]
        public JToken Parameters { get; private set; }

        public override string ToString()
        {
            return JsonConvert.SerializeObject(this, Newtonsoft.Json.Formatting.Indented);
        }
    }
}
