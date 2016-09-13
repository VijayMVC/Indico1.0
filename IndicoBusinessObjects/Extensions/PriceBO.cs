using System;
using System.Collections.Generic;
using System.Linq;
using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class PriceBO : BusinessObject
    {
        #region OnPropertyChange Methods
        // Put implementations of OnBusinessObjectNameBOPropertyNameChanging()
        // and OnBusinessObjectNameBOPropertyNameChanged() here

        #endregion

        #region Extension Methods
        // Put methods to manipulate Business Objects here. Add, Update etc

        public List<PriceStructureForIndico> GetExcelPrices(int distributor)
        {
            IndicoEntities context = (this.Context != null) ? this.Context.Context : new IndicoEntities();
            List<PriceStructureForIndico> lst = new List<PriceStructureForIndico>();
            if (distributor == 0)
            {
                lst = (from p in context.Price
                       join plc in context.PriceLevelCost
                           on p equals plc.Price
                       join dpm in context.DistributorPriceMarkup
                           on plc.PriceLevel equals dpm.PriceLevel
                       where dpm.Distributor.ID == null
                       orderby p.Pattern.ID, p.FabricCode.ID, plc.PriceLevel.ID
                       select new PriceStructureForIndico
                       {
                           SportsCategory = p.Pattern.CoreCategory.Name,
                           OtherCategories = p.Pattern.PatternOtherCategorysWhereThisIsPattern,
                           PatternId = p.Pattern.ID,
                           ItemSubCategory = p.Pattern.SubItem.Name,
                           NickName = p.Pattern.NickName,
                           FabricCodeName = p.FabricCode.Name,
                           PriceLevel = plc.PriceLevel.ID,
                           FactoryCost = plc.FactoryCost,
                           IndimanCost = plc.IndimanCost,
                           IndicoPrice = ((100 * plc.IndimanCost) / (100 - dpm.Markup)),
                           PriceMarkup = dpm.Markup,
                           PriceLevelCostId = plc.ID,
                       }).ToList<PriceStructureForIndico>();
            }
            else
            {
                lst = (from p in context.Price
                       join plc in context.PriceLevelCost
                           on p equals plc.Price
                       join dpm in context.DistributorPriceMarkup
                           on plc.PriceLevel equals dpm.PriceLevel
                       where dpm.Distributor.ID == distributor
                       orderby p.Pattern.ID, p.FabricCode.ID, plc.PriceLevel.ID
                       select new PriceStructureForIndico
                       {
                           SportsCategory = p.Pattern.CoreCategory.Name,
                           OtherCategories = p.Pattern.PatternOtherCategorysWhereThisIsPattern,
                           PatternId = p.Pattern.ID,
                           ItemSubCategory = p.Pattern.SubItem.Name,
                           NickName = p.Pattern.NickName,
                           FabricCodeName = p.FabricCode.Name,
                           PriceLevel = plc.PriceLevel.ID,
                           FactoryCost = plc.FactoryCost,
                           IndimanCost = plc.IndimanCost,
                           IndicoPrice = ((100 * plc.IndimanCost) / (100 - dpm.Markup)),
                           PriceMarkup = dpm.Markup,
                           PriceLevelCostId = plc.ID,
                       }).ToList<PriceStructureForIndico>();
            }
           

            return lst;
        }

        public static ReturnIntViewBO DeletePrice(int? price)
        {
            using (IndicoEntities objContext = new IndicoEntities())
            {
                return ReturnIntViewBO.ToList(objContext.DeletePrice(price))[0];
            }
        }

        public static ReturnIntViewBO GetPrice(string patternNumber, string fabricNickName)
        {
            using (IndicoEntities objContext = new IndicoEntities())
            {
                return ReturnIntViewBO.ToList(objContext.GetPrice(patternNumber, fabricNickName))[0];
            }
        }

        #endregion
    }

    public class PriceStructureForIndico
    {
        public string SportsCategory { get; set; }
        public System.Data.Objects.DataClasses.EntityCollection<Category> OtherCategories { get; set; }
        public int PatternId { get; set; }
        public string ItemSubCategory { get; set; }
        public string NickName { get; set; }
        public string FabricCodeName { get; set; }
        public int PriceLevel { get; set; }
        public decimal FactoryCost { get; set; }
        public decimal IndimanCost { get; set; }
        public decimal IndicoPrice { get; set; }
        public decimal PriceMarkup { get; set; }
        public int PriceLevelCostId { get; set; }
    }
}