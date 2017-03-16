using Newtonsoft.Json;

namespace ZohoProxy
{
    public class ZohoReqeustError
    {
        [JsonProperty("code")]
        public string Code;

        [JsonProperty("message")]
        public string Message;
    }
}
