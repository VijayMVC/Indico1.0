using System.Collections.Generic;

namespace ZohoProxy
{
    public class ZohoCRMProduct : ZohoCRMModuleBase
    {
        public ZohoCRMProduct(string authToken) : base(authToken)
        {
            this.ModuleName = "Products";
        }

        public List<ZohoProduct> SearchProductsByName(string name, int fromIndex = 1, int toIndex = 20)
        {
            var results = new List<ZohoProduct>();
            var result = base.SearchRecordsBase(string.Format("(Product Name:{0})", name), fromIndex, toIndex).Result;
            foreach (var r in result)
            {
                results.Add(GetZohoProduct(r));
            }

            return results;
        }

        public ZohoProduct GetRecordById(string id)
        {
            var result = base.GetRecordByIdBase(id).Result;
            if (result == null || result.Count == 0) return null;

            return GetZohoProduct(result[0]);
        }

        public List<ZohoProduct> GetRecords(int fromIndex = 1, int toIndex = 20)
        {
            var results = new List<ZohoProduct>();
            var result = base.GetRecordsBase(fromIndex, toIndex).Result;
            foreach (var r in result)
            {
                results.Add(GetZohoProduct(r));
            }

            return results;
        }

        private ZohoProduct GetZohoProduct(GetRecordResult recordResult)
        {
            var result = new ZohoProduct();

            foreach (var fl in recordResult.Fields)
            {
                SetObjectProperty<ZohoProduct>(result, fl.Value, fl.Content);

                //switch (fl.Value)
                //{
                //    case "PRODUCTID":
                //        result.Id = fl.Content;
                //        break;
                //    case "Product Name":
                //        result.ProductName = fl.Content;
                //        break;
                //    case "SMOWNERID":
                //        result.OwnerId = fl.Content;
                //        break;
                //    case "Product Owner":
                //        result.OwnerName = fl.Content;
                //        break;
                //    case "Product Code":
                //        result.ProductCode = fl.Content;
                //        break;
                //    case "Product Active":
                //        result.ProductActive = fl.Content.Trim().ToLower() == "true";
                //        break;
                //    case "Manufacturer":
                //        result.Manufacturer = fl.Content;
                //        break;
                //    case "Product Category":
                //        result.ProductCategory = fl.Content;
                //        break;
                //    case "SMCREATORID":
                //        result.CreatorId = fl.Content;
                //        break;
                //    case "Created By":
                //        result.CreatedBy = fl.Content;
                //        break;
                //    case "MODIFIEDBY":
                //        result.ModifiedBy = fl.Content;
                //        break;
                //    case "Modified By":
                //        result.ModifiedName = fl.Content;
                //        break;
                //    case "Created Time":
                //        result.CreatedTime = DateTime.Parse(fl.Content);
                //        break;
                //    case "Modified Time":
                //        result.ModifiedTime = DateTime.Parse(fl.Content);
                //        break;
                //    case "Unit Price":
                //        result.UnitPrice = decimal.Parse(fl.Content);
                //        break;
                //    case "Commission Rate":
                //        result.CommissionRate = decimal.Parse(fl.Content);
                //        break;
                //    case "Tax":
                //        result.Tax = fl.Content;
                //        break;
                //    case "Usage Unit":
                //        result.UsageUnit = fl.Content;
                //        break;
                //    case "Qty Ordered":
                //        result.QtyOrdered = int.Parse(fl.Content);
                //        break;
                //    case "Qty in Stock":
                //        result.QtyinStock = int.Parse(fl.Content);
                //        break;
                //    case "Reorder Level":
                //        result.ReorderLevel = int.Parse(fl.Content);
                //        break;
                //    case "Qty in Demand":
                //        result.QtyinDemand = int.Parse(fl.Content);
                //        break;
                //    case "Description":
                //        result.Description = fl.Content;
                //        break;
                //    case "Taxable":
                //        result.Taxable = fl.Content.Trim().ToLower() == "true";
                //        break;
                //    case "Qty Band Min":
                //        result.QtyBandMin = int.Parse(fl.Content);
                //        break;
                //    case "Qty Band Max":
                //        result.QtyBandMax = int.Parse(fl.Content);
                //        break;
                //    default:
                //        break;
                //}
            }

            return result;
        }
    }
}
