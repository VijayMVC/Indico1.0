using Indico.BusinessObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace IndicoService.Controllers
{
    public class CategoriesController : ApiController
    {
        private List<PatternBO> listPaternCategory = null;
        private List<CategoryBO> listCategory = null;

        private List<PatternBO> PatternCategorySource
        {
            get
            {
                if (listPaternCategory == null || listCategory.GetType() != typeof(List<PatternBO>))
                {
                    PatternBO objPattern = new PatternBO();
                    objPattern.IsActiveWS = true;
                    listPaternCategory = objPattern.SearchObjects();
                }

                return listPaternCategory;
            }
        }

        private List<CategoryBO> CategorySource
        {
            get
            {
                if (listCategory == null || listCategory.GetType() != typeof(List<CategoryBO>))
                {
                    listCategory = new CategoryBO().SearchObjects();
                }
                return listCategory;
            }
        }

        // GET api/Categories
        public IEnumerable<KeyValuePair<string, List<KeyValuePair<int, string>>>> Get()
        {
            List<KeyValuePair<string, List<KeyValuePair<int, string>>>> ListCategoryMenuItems = new List<KeyValuePair<string, List<KeyValuePair<int, string>>>>();

            ListCategoryMenuItems.Add(new KeyValuePair<string, List<KeyValuePair<int, string>>>("Mens", PopulateCategories("Mens")));
            ListCategoryMenuItems.Add(new KeyValuePair<string, List<KeyValuePair<int, string>>>("Ladies", PopulateCategories("Ladies")));
            ListCategoryMenuItems.Add(new KeyValuePair<string, List<KeyValuePair<int, string>>>("Unisex", PopulateCategories("Unisex")));
            ListCategoryMenuItems.Add(new KeyValuePair<string, List<KeyValuePair<int, string>>>("Youth", PopulateCategories("Youth")));
            ListCategoryMenuItems.Add(new KeyValuePair<string, List<KeyValuePair<int, string>>>("Other", PopulateCategories("Other")));

            //return new string[] { "Mens", "Ladies", "Unisex", "Youth", "Other" };

            return ListCategoryMenuItems;
        }

        private List<KeyValuePair<int, string>> PopulateCategories(string MenuItem)
        {
            List<KeyValuePair<int, string>> lstCategoryItems = new List<KeyValuePair<int, string>>();
            //PatternBO objPattern = new PatternBO();
            //objPattern.IsActiveWS = true;
            List<int> lstCategoryIDs = new List<int>();

            //1	MENS
            //2	LADIES
            //3	UNISEX
            //4	N/A
            //5	&nbsp;

            //1	ADULT	
            //2	YOUTH	NULL
            //3	INFANTS	NULL
            //4	N/A	NULL
            //5	FULL RANGE	NULL
            //7	BESPOKE	

            switch (MenuItem)
            {
                case "Mens":
                    lstCategoryIDs = PatternCategorySource.Where(m => m.Gender == 1 && m.AgeGroup == 1).Select(m => m.CoreCategory).Distinct().ToList();
                    break;
                case "Ladies":
                    lstCategoryIDs = PatternCategorySource.Where(m => m.Gender == 2 && m.AgeGroup == 1).Select(m => m.CoreCategory).Distinct().ToList();
                    break;
                case "Unisex":
                    lstCategoryIDs = PatternCategorySource.Where(m => m.Gender == 3).Select(m => m.CoreCategory).Distinct().ToList();
                    break;
                case "Youth":
                    lstCategoryIDs = PatternCategorySource.Where(m => m.AgeGroup == 2).Select(m => m.CoreCategory).Distinct().ToList();
                    break;
                case "Other":
                    lstCategoryIDs = PatternCategorySource.Where(m => m.Gender > 3 || m.AgeGroup > 2).Select(m => m.CoreCategory).Distinct().ToList();
                    break;
                default:
                    break;
            }

            foreach (int CatID in lstCategoryIDs)
            {
                CategoryBO objCat = this.CategorySource.Where(m => m.ID == CatID).SingleOrDefault();
                lstCategoryItems.Add(new KeyValuePair<int, string>(CatID, objCat.Name));
            }

            return lstCategoryItems.OrderBy(m => m.Value).ToList();
        }
    }
}
