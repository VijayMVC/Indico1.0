using System.Collections.Generic;
using Newtonsoft.Json;

namespace ZohoProxy
{
    public class ZohoField
    {
        [JsonProperty("val")]
        public string Value;

        [JsonProperty("content")]
        public string Content;
    }

    public class ZohoPricebookField
    {
        [JsonProperty("val")]
        public string Value;

        [JsonProperty("content")]
        public string Content;

        [JsonProperty("discount")]
        public List<ZohoPricebookDiscount> Discounts;
    }
}
