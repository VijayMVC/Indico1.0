using System.Collections.Generic;
using Newtonsoft.Json;

namespace ZohoProxy
{
    public class GetRecordResult
    {
        [JsonProperty("no")]
        public string ResultNumber;

        [JsonProperty("FL")]
        public List<ZohoField> Fields;

    }

    public class GetRecordPricebookResult
    {
        [JsonProperty("no")]
        public string ResultNumber;

        [JsonProperty("FL")]
        public List<ZohoPricebookField> Fields;
    }

}
