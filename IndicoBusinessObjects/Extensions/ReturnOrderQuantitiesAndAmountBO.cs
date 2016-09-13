using System;
using System.Collections.Generic;
using System.Linq;
//using Indico.BusinessObjects.Util;
using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class ReturnOrderQuantitiesAndAmountBO : BusinessObject
    {

        #region
        public decimal GrossProfit { get; set; }
        public decimal GrossMargin { get; set; }
        public int PurchasePrice { get; set; }
        #endregion


        #region Extension Methods
        // Put methods to manipulate Business Objects here. Add, Update etc

        internal static List<Indico.BusinessObjects.ReturnOrderQuantitiesAndAmountBO> ToList(IEnumerable<Indico.DAL.ReturnOrderQuantitiesAndAmount> oQuery)
        {
            List<Indico.DAL.ReturnOrderQuantitiesAndAmount> oList = oQuery.ToList();
            List<Indico.BusinessObjects.ReturnOrderQuantitiesAndAmountBO> rList = new List<Indico.BusinessObjects.ReturnOrderQuantitiesAndAmountBO>(oList.Count);
            foreach (Indico.DAL.ReturnOrderQuantitiesAndAmount o in oList)
            {
                Indico.BusinessObjects.ReturnOrderQuantitiesAndAmountBO obj = new Indico.BusinessObjects.ReturnOrderQuantitiesAndAmountBO(o);
                rList.Add(obj);
            }

            return rList;
        }

        #endregion


    }
}

