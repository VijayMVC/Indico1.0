using System;

namespace Indico.Models
{
    public class GetPatternDevelopmentHistoryModel
    { 
        public string UserName { get; set; }
        public DateTime? ModifiedDate { get; set; }
        public string ChangeDescription { get; set; }
    }
}