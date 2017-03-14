using System;
using System.ComponentModel;
using Newtonsoft.Json;

namespace ZohoProxy
{
    public class ZohoInsertResult
    {
        [JsonProperty("message")]
        public string Message { get; set; }

        [JsonProperty("recorddetail")]
        public GetRecordResult RecordDetail { get; set; }
    }

    public class ZohoInsertUpdateDetail
    {
        public string Id;

        [Description("Created By")]
        public string CreatedBy;
        
        [Description("Modified By")]
        public string ModifiedBy;

        [Description("Created Time")]
        public DateTime CreatedTime;

        [Description("Modified Time")]
        public DateTime ModifiedTime;

        public string Message;
    }
}
