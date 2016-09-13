using System;
using System.Collections.Generic;
using System.Linq;
//using Indico.BusinessObjects.Util;
using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class ReturnDetailReportByClientBO : BusinessObject
    {
        #region
        public decimal GrossProfit { get; set; }
        public decimal GrossMargin { get; set; }
        public int PurchasePrice { get; set; }
        #endregion


        #region Extension Methods
        // Put methods to manipulate Business Objects here. Add, Update etc
        #endregion
    }
}

