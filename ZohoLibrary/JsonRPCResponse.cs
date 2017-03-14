using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace ZohoLibrary
{
    public class JsonRPCResponse
    {
        [JsonProperty("jsonrpc", Required = Required.Always)]
        public string Version;

        /// <summary>Unique Request Id.</summary>
        [JsonProperty("id", Required = Required.Always)]
        public string Id;

        /// <summary>The error. NULL if no error occured.</summary>
        [JsonProperty("error", Required = Required.Default)]
        public JsonRPCError Error;

        [JsonProperty("result", Required = Required.Default)]
        public JToken Result;

        public override string ToString()
        {
            return JsonConvert.SerializeObject(this, Newtonsoft.Json.Formatting.Indented);
        }
    }
}
