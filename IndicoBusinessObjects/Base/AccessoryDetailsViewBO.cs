// This file is generated by CodeSmith. Do not edit. All edits to this file will be lost. 
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic;
using System.Linq.Expressions;
using System.Reflection;
using System.Xml.Serialization;

//using Indico.BusinessObjects.Util;
//using Indico.BusinessObjects;
using Indico.DAL;


namespace Indico.BusinessObjects
{
    /// <summary>
    /// AccessoryDetailsViewBO provides the business logic for maintaining Indico.DAL.AccessoryDetailsView records in the data store.
    /// </summary>
    /// <remarks>
    /// AccessoryDetailsViewBO provides the business logic for maintaining Indico.DAL.AccessoryDetailsView records in the data store. 
    /// By default it provides basic Search methods for retrieving Indico.DAL.AccessoryDetailsView
    /// records using the AccessoryDetailsView DAL class. Other methods implement atomic chunks of Business Logic according to
    /// the business rules.
    /// </remarks>
    public partial class AccessoryDetailsViewBO : BusinessObject, IComparable
    {
        #region fields
        private int? _accessory;
        private string _name;
        private string _code;
        private int? _accessoryCategoryID;
        private string _accessoryCategory;
        private string _description;
        private decimal? _cost;
        private string _suppCode;
        private int? _unitID;
        private string _unit;
        private int? _supplierID;
        private string _supplier;
        private bool? _isPatternAccessoryWherethisAccessory;
        private bool? _isPatternSupportAccessorySubWherethisAccessory;
        private bool? _isVisualLayoutAccessorySubWherethisAccessory;
        #endregion
        
        #region Properties
        /// <summary></summary>
        public int? Accessory
        {   get {return _accessory;}
            set 
            {
                _accessory = value;
            }
        }
        /// <summary></summary>
        public string Name
        {   get {return _name;}
            set 
            {
                _name = value;
            }
        }
        /// <summary></summary>
        public string Code
        {   get {return _code;}
            set 
            {
                _code = value;
            }
        }
        /// <summary></summary>
        public int? AccessoryCategoryID
        {   get {return _accessoryCategoryID;}
            set 
            {
                _accessoryCategoryID = value;
            }
        }
        /// <summary></summary>
        public string AccessoryCategory
        {   get {return _accessoryCategory;}
            set 
            {
                _accessoryCategory = value;
            }
        }
        /// <summary></summary>
        public string Description
        {   get {return _description;}
            set 
            {
                _description = value;
            }
        }
        /// <summary></summary>
        public decimal? Cost
        {   get {return _cost;}
            set 
            {
                _cost = value;
            }
        }
        /// <summary></summary>
        public string SuppCode
        {   get {return _suppCode;}
            set 
            {
                _suppCode = value;
            }
        }
        /// <summary></summary>
        public int? UnitID
        {   get {return _unitID;}
            set 
            {
                _unitID = value;
            }
        }
        /// <summary></summary>
        public string Unit
        {   get {return _unit;}
            set 
            {
                _unit = value;
            }
        }
        /// <summary></summary>
        public int? SupplierID
        {   get {return _supplierID;}
            set 
            {
                _supplierID = value;
            }
        }
        /// <summary></summary>
        public string Supplier
        {   get {return _supplier;}
            set 
            {
                _supplier = value;
            }
        }
        /// <summary></summary>
        public bool? IsPatternAccessoryWherethisAccessory
        {   get {return _isPatternAccessoryWherethisAccessory;}
            set 
            {
                _isPatternAccessoryWherethisAccessory = value;
            }
        }
        /// <summary></summary>
        public bool? IsPatternSupportAccessorySubWherethisAccessory
        {   get {return _isPatternSupportAccessorySubWherethisAccessory;}
            set 
            {
                _isPatternSupportAccessorySubWherethisAccessory = value;
            }
        }
        /// <summary></summary>
        public bool? IsVisualLayoutAccessorySubWherethisAccessory
        {   get {return _isVisualLayoutAccessorySubWherethisAccessory;}
            set 
            {
                _isVisualLayoutAccessorySubWherethisAccessory = value;
            }
        }
        #endregion
        
        #region Internal Constructors
        /// <summary>
        /// Creates an instance of the AccessoryDetailsViewBO class using the supplied Indico.DAL.AccessoryDetailsView. 
        /// </summary>
        /// <param name="obj">a Indico.DAL.AccessoryDetailsView whose properties will be used to initialise the AccessoryDetailsViewBO</param>
        internal AccessoryDetailsViewBO(Indico.DAL.AccessoryDetailsView obj)
        {
            // set the properties from the Indico.DAL.AccessoryDetailsView 
            this.Accessory = obj.Accessory;
            this.Name = obj.Name;
            this.Code = obj.Code;
            this.AccessoryCategoryID = obj.AccessoryCategoryID;
            this.AccessoryCategory = obj.AccessoryCategory;
            this.Description = obj.Description;
            this.Cost = obj.Cost;
            this.SuppCode = obj.SuppCode;
            this.UnitID = obj.UnitID;
            this.Unit = obj.Unit;
            this.SupplierID = obj.SupplierID;
            this.Supplier = obj.Supplier;
            this.IsPatternAccessoryWherethisAccessory = obj.IsPatternAccessoryWherethisAccessory;
            this.IsPatternSupportAccessorySubWherethisAccessory = obj.IsPatternSupportAccessorySubWherethisAccessory;
            this.IsVisualLayoutAccessorySubWherethisAccessory = obj.IsVisualLayoutAccessorySubWherethisAccessory;
        }
        #endregion
        
        #region Internal utility methods
        internal void SetDAL(Indico.DAL.AccessoryDetailsView obj, IndicoEntities context)
        {
            // set the Indico.DAL.AccessoryDetailsView properties
            obj.Accessory = Convert.ToInt32(Accessory);
            obj.Name = Name;
            obj.Code = Code;
            obj.AccessoryCategoryID = Convert.ToInt32(AccessoryCategoryID);
            obj.AccessoryCategory = AccessoryCategory;
            obj.Description = Description;
            obj.Cost = Convert.ToDecimal(Cost);
            obj.SuppCode = SuppCode;
            obj.UnitID = Convert.ToInt32(UnitID);
            obj.Unit = Unit;
            obj.SupplierID = Convert.ToInt32(SupplierID);
            obj.Supplier = Supplier;
            obj.IsPatternAccessoryWherethisAccessory = Convert.ToBoolean(IsPatternAccessoryWherethisAccessory);
            obj.IsPatternSupportAccessorySubWherethisAccessory = Convert.ToBoolean(IsPatternSupportAccessorySubWherethisAccessory);
            obj.IsVisualLayoutAccessorySubWherethisAccessory = Convert.ToBoolean(IsVisualLayoutAccessorySubWherethisAccessory);
        }
        
        internal void SetBO(Indico.DAL.AccessoryDetailsView obj)
        {
            // set the Indico.BusinessObjects.AccessoryDetailsViewBO properties    
            this.Accessory = obj.Accessory;
            this.Name = obj.Name;
            this.Code = obj.Code;
            this.AccessoryCategoryID = obj.AccessoryCategoryID;
            this.AccessoryCategory = obj.AccessoryCategory;
            this.Description = obj.Description;
            this.Cost = obj.Cost;
            this.SuppCode = obj.SuppCode;
            this.UnitID = obj.UnitID;
            this.Unit = obj.Unit;
            this.SupplierID = obj.SupplierID;
            this.Supplier = obj.Supplier;
            this.IsPatternAccessoryWherethisAccessory = obj.IsPatternAccessoryWherethisAccessory;
            this.IsPatternSupportAccessorySubWherethisAccessory = obj.IsPatternSupportAccessorySubWherethisAccessory;
            this.IsVisualLayoutAccessorySubWherethisAccessory = obj.IsVisualLayoutAccessorySubWherethisAccessory;
        }
        
        internal void SetBO(Indico.BusinessObjects.AccessoryDetailsViewBO obj)
        {
            // set this Indico.BusinessObjects.AccessoryDetailsViewBO properties
            this.Accessory = obj.Accessory;
            this.Name = obj.Name;
            this.Code = obj.Code;
            this.AccessoryCategoryID = obj.AccessoryCategoryID;
            this.AccessoryCategory = obj.AccessoryCategory;
            this.Description = obj.Description;
            this.Cost = obj.Cost;
            this.SuppCode = obj.SuppCode;
            this.UnitID = obj.UnitID;
            this.Unit = obj.Unit;
            this.SupplierID = obj.SupplierID;
            this.Supplier = obj.Supplier;
            this.IsPatternAccessoryWherethisAccessory = obj.IsPatternAccessoryWherethisAccessory;
            this.IsPatternSupportAccessorySubWherethisAccessory = obj.IsPatternSupportAccessorySubWherethisAccessory;
            this.IsVisualLayoutAccessorySubWherethisAccessory = obj.IsVisualLayoutAccessorySubWherethisAccessory;
        }
        
        private static List<Indico.BusinessObjects.AccessoryDetailsViewBO> IQueryableToList(IQueryable<Indico.DAL.AccessoryDetailsView> oQuery)
        {
            List<Indico.DAL.AccessoryDetailsView> oList = oQuery.ToList();
            List<Indico.BusinessObjects.AccessoryDetailsViewBO> rList = new List<Indico.BusinessObjects.AccessoryDetailsViewBO>(oList.Count);
            foreach (Indico.DAL.AccessoryDetailsView o in oList)
            {
                Indico.BusinessObjects.AccessoryDetailsViewBO obj = new Indico.BusinessObjects.AccessoryDetailsViewBO(o);
                rList.Add(obj);
            }
            return rList;
        }
        #endregion
        
        #region BusinessObject methods
        
        #region GetAllObject
        public static List<Indico.BusinessObjects.AccessoryDetailsViewBO> GetAllObject()
        {
            return GetAllObject(0, 0);
        }
        public static List<Indico.BusinessObjects.AccessoryDetailsViewBO> GetAllObject(int maximumRows)
        {
            return GetAllObject(maximumRows, 0);
        }
        public static List<Indico.BusinessObjects.AccessoryDetailsViewBO> GetAllObject(int maximumRows, int startIndex)
        {
            return GetAllObject(maximumRows, startIndex, null, false);
        }
        public static List<Indico.BusinessObjects.AccessoryDetailsViewBO> GetAllObject(int maximumRows, int startIndex, string sortExpression, bool sortDescending)
        {
            IndicoEntities context = new IndicoEntities();
            IQueryable<Indico.DAL.AccessoryDetailsView> oQuery =
                (from o in context.AccessoryDetailsView
                 orderby o.Accessory
                 select o);

            if (sortExpression != null && sortExpression.Length > 0)
            {
                // using System.Linq.Dynamic here in Dynamic.cs;
                if (sortDescending)
                    oQuery = oQuery.OrderBy(sortExpression + " desc").Skip(startIndex).Take((maximumRows == 0) ? Int32.MaxValue : maximumRows);
                else
                    oQuery = oQuery.OrderBy(sortExpression + " asc").Skip(startIndex).Take((maximumRows == 0) ? Int32.MaxValue : maximumRows);
            }
            else
                oQuery = oQuery.OrderBy(obj => obj.Accessory).Skip(startIndex).Take((maximumRows == 0) ? Int32.MaxValue : maximumRows);

            List<Indico.BusinessObjects.AccessoryDetailsViewBO> accessorydetailsviews = IQueryableToList(oQuery);
            context.Dispose();
            return accessorydetailsviews;
        }
        #endregion
        
        #region SearchObjects
        public List<Indico.BusinessObjects.AccessoryDetailsViewBO> SearchObjects()
        {
            return SearchObjects(0,0);
        }
        public List<Indico.BusinessObjects.AccessoryDetailsViewBO> SearchObjects(int maximumRows)
        {
            return SearchObjects(maximumRows, 0);
        }
        public List<Indico.BusinessObjects.AccessoryDetailsViewBO> SearchObjects(int maximumRows, int startIndex)
        {
            return SearchObjects(maximumRows, startIndex, null, false);
        }
        public List<Indico.BusinessObjects.AccessoryDetailsViewBO> SearchObjects(int maximumRows, int startIndex, string sortExpression, bool sortDescending)
        {
            IndicoEntities context = new IndicoEntities();
            IQueryable<Indico.DAL.AccessoryDetailsView> oQuery =
                (from o in context.AccessoryDetailsView
                 where
                    (this.Accessory == null || this.Accessory == o.Accessory) &&
                    (this.Name == null || this.Name == o.Name) &&
                    (this.Code == null || this.Code == o.Code) &&
                    (this.AccessoryCategoryID == null || this.AccessoryCategoryID == o.AccessoryCategoryID) &&
                    (this.AccessoryCategory == null || this.AccessoryCategory == o.AccessoryCategory) &&
                    (this.Description == null || this.Description == o.Description) &&
                    (this.Cost == null || this.Cost == o.Cost) &&
                    (this.SuppCode == null || this.SuppCode == o.SuppCode) &&
                    (this.UnitID == null || this.UnitID == o.UnitID) &&
                    (this.Unit == null || this.Unit == o.Unit) &&
                    (this.SupplierID == null || this.SupplierID == o.SupplierID) &&
                    (this.Supplier == null || this.Supplier == o.Supplier) &&
                    (this.IsPatternAccessoryWherethisAccessory == null || this.IsPatternAccessoryWherethisAccessory == o.IsPatternAccessoryWherethisAccessory) &&
                    (this.IsPatternSupportAccessorySubWherethisAccessory == null || this.IsPatternSupportAccessorySubWherethisAccessory == o.IsPatternSupportAccessorySubWherethisAccessory) &&
                    (this.IsVisualLayoutAccessorySubWherethisAccessory == null || this.IsVisualLayoutAccessorySubWherethisAccessory == o.IsVisualLayoutAccessorySubWherethisAccessory) 
                 orderby o.Accessory
                 select o);

            if (sortExpression != null && sortExpression.Length > 0)
            {
                // using System.Linq.Dynamic here in Dynamic.cs;
                if (sortDescending)
                    oQuery = oQuery.OrderBy(sortExpression + " desc").Skip(startIndex).Take((maximumRows == 0) ? Int32.MaxValue : maximumRows);
                else
                    oQuery = oQuery.OrderBy(sortExpression + " asc").Skip(startIndex).Take((maximumRows == 0) ? Int32.MaxValue : maximumRows);
            }
            else
                oQuery = oQuery.OrderBy(obj => obj.Accessory).Skip(startIndex).Take((maximumRows == 0) ? Int32.MaxValue : maximumRows);

            List<Indico.BusinessObjects.AccessoryDetailsViewBO> accessorydetailsviews = IQueryableToList(oQuery);
            context.Dispose();
            return accessorydetailsviews;
        }
        
        public int SearchObjectsCount()
        {
            IndicoEntities context = new IndicoEntities();
            return (from o in context.AccessoryDetailsView
                 where
                    (this.Accessory == null || this.Accessory == o.Accessory) &&
                    (this.Name == null || this.Name == o.Name) &&
                    (this.Code == null || this.Code == o.Code) &&
                    (this.AccessoryCategoryID == null || this.AccessoryCategoryID == o.AccessoryCategoryID) &&
                    (this.AccessoryCategory == null || this.AccessoryCategory == o.AccessoryCategory) &&
                    (this.Description == null || this.Description == o.Description) &&
                    (this.Cost == null || this.Cost == o.Cost) &&
                    (this.SuppCode == null || this.SuppCode == o.SuppCode) &&
                    (this.UnitID == null || this.UnitID == o.UnitID) &&
                    (this.Unit == null || this.Unit == o.Unit) &&
                    (this.SupplierID == null || this.SupplierID == o.SupplierID) &&
                    (this.Supplier == null || this.Supplier == o.Supplier) &&
                    (this.IsPatternAccessoryWherethisAccessory == null || this.IsPatternAccessoryWherethisAccessory == o.IsPatternAccessoryWherethisAccessory) &&
                    (this.IsPatternSupportAccessorySubWherethisAccessory == null || this.IsPatternSupportAccessorySubWherethisAccessory == o.IsPatternSupportAccessorySubWherethisAccessory) &&
                    (this.IsVisualLayoutAccessorySubWherethisAccessory == null || this.IsVisualLayoutAccessorySubWherethisAccessory == o.IsVisualLayoutAccessorySubWherethisAccessory) 
                 orderby o.Accessory
                 select o).Count();
        }
        #endregion
        
        #region SearchObjectsLikeAnd
        public List<Indico.BusinessObjects.AccessoryDetailsViewBO> SearchLikeAndObjects()
        {
            return SearchLikeAndObjects(0);
        }
        public List<Indico.BusinessObjects.AccessoryDetailsViewBO> SearchLikeAndObjects(int maximumRows)
        {
            return SearchLikeAndObjects(maximumRows, 0);
        }
        public List<Indico.BusinessObjects.AccessoryDetailsViewBO> SearchLikeAndObjects(int maximumRows, int startIndex)
        {
            return SearchLikeAndObjects(maximumRows, startIndex, null, false);
        }
        public List<Indico.BusinessObjects.AccessoryDetailsViewBO> SearchLikeAndObjects(int maximumRows, int startIndex, string sortExpression, bool sortDescending)
        {
            IndicoEntities context = new IndicoEntities();
            IQueryable<Indico.DAL.AccessoryDetailsView> oQuery =
                (from o in context.AccessoryDetailsView
                 where
                    (this.Accessory == null || o.Accessory == this.Accessory) &&
                    (this.Name == null || o.Name.Contains(this.Name)) &&
                    (this.Code == null || o.Code.Contains(this.Code)) &&
                    (this.AccessoryCategoryID == null || o.AccessoryCategoryID == this.AccessoryCategoryID) &&
                    (this.AccessoryCategory == null || o.AccessoryCategory.Contains(this.AccessoryCategory)) &&
                    (this.Description == null || o.Description.Contains(this.Description)) &&
                    (this.Cost == null || o.Cost == this.Cost) &&
                    (this.SuppCode == null || o.SuppCode.Contains(this.SuppCode)) &&
                    (this.UnitID == null || o.UnitID == this.UnitID) &&
                    (this.Unit == null || o.Unit.Contains(this.Unit)) &&
                    (this.SupplierID == null || o.SupplierID == this.SupplierID) &&
                    (this.Supplier == null || o.Supplier.Contains(this.Supplier)) &&
                    (this.IsPatternAccessoryWherethisAccessory == null || o.IsPatternAccessoryWherethisAccessory == this.IsPatternAccessoryWherethisAccessory) &&
                    (this.IsPatternSupportAccessorySubWherethisAccessory == null || o.IsPatternSupportAccessorySubWherethisAccessory == this.IsPatternSupportAccessorySubWherethisAccessory) &&
                    (this.IsVisualLayoutAccessorySubWherethisAccessory == null || o.IsVisualLayoutAccessorySubWherethisAccessory == this.IsVisualLayoutAccessorySubWherethisAccessory) 
                 orderby o.Accessory
                 select o);

            if (sortExpression != null && sortExpression.Length > 0)
            {
                // using System.Linq.Dynamic here in Dynamic.cs;
                if (sortDescending)
                    oQuery = oQuery.OrderBy(sortExpression + " desc").Skip(startIndex).Take((maximumRows == 0) ? Int32.MaxValue : maximumRows);
                else
                    oQuery = oQuery.OrderBy(sortExpression + " asc").Skip(startIndex).Take((maximumRows == 0) ? Int32.MaxValue : maximumRows);
            }
            else
                oQuery = oQuery.OrderBy(obj => obj.Accessory).Skip(startIndex).Take((maximumRows == 0) ? Int32.MaxValue : maximumRows);

            List<Indico.BusinessObjects.AccessoryDetailsViewBO> accessorydetailsviews = IQueryableToList(oQuery);
            context.Dispose();
            return accessorydetailsviews;
        }
        
        public int SearchLikeAndObjectsCount()
        {
            IndicoEntities context = new IndicoEntities();
            return (from o in context.AccessoryDetailsView
                 where
                    (this.Accessory == null || o.Accessory == this.Accessory) &&
                    (this.Name == null || o.Name.Contains(this.Name)) &&
                    (this.Code == null || o.Code.Contains(this.Code)) &&
                    (this.AccessoryCategoryID == null || o.AccessoryCategoryID == this.AccessoryCategoryID) &&
                    (this.AccessoryCategory == null || o.AccessoryCategory.Contains(this.AccessoryCategory)) &&
                    (this.Description == null || o.Description.Contains(this.Description)) &&
                    (this.Cost == null || o.Cost == this.Cost) &&
                    (this.SuppCode == null || o.SuppCode.Contains(this.SuppCode)) &&
                    (this.UnitID == null || o.UnitID == this.UnitID) &&
                    (this.Unit == null || o.Unit.Contains(this.Unit)) &&
                    (this.SupplierID == null || o.SupplierID == this.SupplierID) &&
                    (this.Supplier == null || o.Supplier.Contains(this.Supplier)) &&
                    (this.IsPatternAccessoryWherethisAccessory == null || o.IsPatternAccessoryWherethisAccessory == this.IsPatternAccessoryWherethisAccessory) &&
                    (this.IsPatternSupportAccessorySubWherethisAccessory == null || o.IsPatternSupportAccessorySubWherethisAccessory == this.IsPatternSupportAccessorySubWherethisAccessory) &&
                    (this.IsVisualLayoutAccessorySubWherethisAccessory == null || o.IsVisualLayoutAccessorySubWherethisAccessory == this.IsVisualLayoutAccessorySubWherethisAccessory) 
                 orderby o.Accessory
                 select o).Count();
            
        }
        
        #endregion
        
        #region SearchObjectsLikeOr
        public List<Indico.BusinessObjects.AccessoryDetailsViewBO> SearchLikeOrObjects()
        {
            return SearchLikeOrObjects(0);
        }
        public List<Indico.BusinessObjects.AccessoryDetailsViewBO> SearchLikeOrObjects(int maximumRows)
        {
            return SearchLikeOrObjects(maximumRows, 0);
        }
        public List<Indico.BusinessObjects.AccessoryDetailsViewBO> SearchLikeOrObjects(int maximumRows, int startIndex)
        {
            return SearchLikeOrObjects(maximumRows, startIndex, null, false);
        }
        public List<Indico.BusinessObjects.AccessoryDetailsViewBO> SearchLikeOrObjects(int maximumRows, int startIndex, string sortExpression, bool sortDescending)
        {
            IndicoEntities context = new IndicoEntities();
            IQueryable<Indico.DAL.AccessoryDetailsView> oQuery =
                (from o in context.AccessoryDetailsView
                 where
                    (this.Accessory == null || this.Accessory == o.Accessory) && 
                    (this.AccessoryCategoryID == null || this.AccessoryCategoryID == o.AccessoryCategoryID) && 
                    (this.Cost == null || this.Cost == o.Cost) && 
                    (this.UnitID == null || this.UnitID == o.UnitID) && 
                    (this.SupplierID == null || this.SupplierID == o.SupplierID) && 
                    (this.IsPatternAccessoryWherethisAccessory == null || this.IsPatternAccessoryWherethisAccessory == o.IsPatternAccessoryWherethisAccessory) && 
                    (this.IsPatternSupportAccessorySubWherethisAccessory == null || this.IsPatternSupportAccessorySubWherethisAccessory == o.IsPatternSupportAccessorySubWherethisAccessory) && 
                    (this.IsVisualLayoutAccessorySubWherethisAccessory == null || this.IsVisualLayoutAccessorySubWherethisAccessory == o.IsVisualLayoutAccessorySubWherethisAccessory) && 
                    ((o.Name.Contains(this.Name)) ||
                    (o.Code.Contains(this.Code)) ||
                    (o.AccessoryCategory.Contains(this.AccessoryCategory)) ||
                    (o.Description.Contains(this.Description)) ||
                    (o.SuppCode.Contains(this.SuppCode)) ||
                    (o.Unit.Contains(this.Unit)) ||
                    (o.Supplier.Contains(this.Supplier)) ||
                    (this.Name == null && this.Code == null && this.AccessoryCategory == null && this.Description == null && this.SuppCode == null && this.Unit == null && this.Supplier == null ))
                 orderby o.Accessory
                 select o);

            if (sortExpression != null && sortExpression.Length > 0)
            {
                // using System.Linq.Dynamic here in Dynamic.cs;
                if (sortDescending)
                    oQuery = oQuery.OrderBy(sortExpression + " desc").Skip(startIndex).Take((maximumRows == 0) ? Int32.MaxValue : maximumRows);
                else
                    oQuery = oQuery.OrderBy(sortExpression + " asc").Skip(startIndex).Take((maximumRows == 0) ? Int32.MaxValue : maximumRows);
            }
            else
                oQuery = oQuery.OrderBy(obj => obj.Accessory).Skip(startIndex).Take((maximumRows == 0) ? Int32.MaxValue : maximumRows);

            List<Indico.BusinessObjects.AccessoryDetailsViewBO> accessorydetailsviews = IQueryableToList(oQuery);
            context.Dispose();
            return accessorydetailsviews;
        }
        
        public int SearchLikeOrObjectsCount()
        {
            IndicoEntities context = new IndicoEntities();
            return (from o in context.AccessoryDetailsView
                 where
                    (this.Accessory == null || this.Accessory == o.Accessory) && 
                    (this.AccessoryCategoryID == null || this.AccessoryCategoryID == o.AccessoryCategoryID) && 
                    (this.Cost == null || this.Cost == o.Cost) && 
                    (this.UnitID == null || this.UnitID == o.UnitID) && 
                    (this.SupplierID == null || this.SupplierID == o.SupplierID) && 
                    (this.IsPatternAccessoryWherethisAccessory == null || this.IsPatternAccessoryWherethisAccessory == o.IsPatternAccessoryWherethisAccessory) && 
                    (this.IsPatternSupportAccessorySubWherethisAccessory == null || this.IsPatternSupportAccessorySubWherethisAccessory == o.IsPatternSupportAccessorySubWherethisAccessory) && 
                    (this.IsVisualLayoutAccessorySubWherethisAccessory == null || this.IsVisualLayoutAccessorySubWherethisAccessory == o.IsVisualLayoutAccessorySubWherethisAccessory) && 
                    ((o.Name.Contains(this.Name)) ||
                    (o.Code.Contains(this.Code)) ||
                    (o.AccessoryCategory.Contains(this.AccessoryCategory)) ||
                    (o.Description.Contains(this.Description)) ||
                    (o.SuppCode.Contains(this.SuppCode)) ||
                    (o.Unit.Contains(this.Unit)) ||
                    (o.Supplier.Contains(this.Supplier)) ||
                    (this.Name == null && this.Code == null && this.AccessoryCategory == null && this.Description == null && this.SuppCode == null && this.Unit == null && this.Supplier == null ))
                 orderby o.Accessory
                 select o).Count();
            
        }
        #endregion
        
        #region Serialization methods
        /// <summary>
        /// Serializes the Indico.BusinessObjects.AccessoryDetailsViewBO to an XML representation
        /// </summary>
        /// <returns>a XML string serialized representation</returns>
        public string SerializeObject()
        {
            string strReturn = "";

            System.IO.MemoryStream objStream = new System.IO.MemoryStream();

            System.Xml.Serialization.XmlSerializer x = new System.Xml.Serialization.XmlSerializer(this.GetType());

            x.Serialize(objStream, this);

            System.Text.Encoding encoding = System.Text.Encoding.UTF8;
            // Read string from binary file with UTF8 encoding
            strReturn = encoding.GetString(objStream.GetBuffer());

            objStream.Close();
            return strReturn;

        }

        /// <summary>
        /// Deserializes Indico.BusinessObjects.AccessoryDetailsViewBO object from an XML representation
        /// </summary>
        /// <param name="strXML">a XML string serialized representation</param>
        public Indico.BusinessObjects.AccessoryDetailsViewBO DeserializeObject(string strXML)
        {
            Indico.BusinessObjects.AccessoryDetailsViewBO objTemp = null;
            System.Xml.XmlDocument objXML = new System.Xml.XmlDocument();

            objXML.LoadXml(strXML);
            System.Text.Encoding encoding = System.Text.Encoding.UTF8;

            System.IO.MemoryStream objStream = new System.IO.MemoryStream();
            byte[] b = encoding.GetBytes(objXML.OuterXml);

            objStream.Write(b, 0, (int)b.Length);
            objStream.Position = 0;
            System.Xml.Serialization.XmlSerializer x = new System.Xml.Serialization.XmlSerializer(this.GetType());

            objTemp = (Indico.BusinessObjects.AccessoryDetailsViewBO)x.Deserialize(objStream);
            objStream.Close();
            return objTemp;
        }

        /// <summary>
        /// Returns a simple XML representation of Indico.BusinessObjects.AccessoryDetailsViewBO object in an XmlElement
        /// </summary>
        /// <returns>An XML snippet representing the object</returns>
        public string ToXmlString()
        {
            // MW TODO - implement this better.
            return SerializeObject();
        }
        #endregion
        
        #region IComparable Members

        public int CompareTo(object obj)
        {
            if (!(obj is Indico.BusinessObjects.AccessoryDetailsViewBO))
                return 1;
            Indico.BusinessObjects.AccessoryDetailsViewBOComparer c = new Indico.BusinessObjects.AccessoryDetailsViewBOComparer();
            return c.Compare(this, obj as Indico.BusinessObjects.AccessoryDetailsViewBO);
        }

        #endregion
        #endregion
    }
    
    #region AccessoryDetailsViewBOComparer
    public class AccessoryDetailsViewBOComparer : IComparer<Indico.BusinessObjects.AccessoryDetailsViewBO>
    {
        private string propertyToCompareName;
        public AccessoryDetailsViewBOComparer(string propertyToCompare)
        {
            PropertyInfo p = typeof(Indico.BusinessObjects.AccessoryDetailsViewBO).GetProperty(propertyToCompare);
            if (p == null)
                throw new ArgumentException("is not a public property of Indico.BusinessObjects.AccessoryDetailsViewBO", "propertyToCompare");
            this.propertyToCompareName = propertyToCompare;
        }
        
        public AccessoryDetailsViewBOComparer()
        {
        
        }

        #region IComparer<Indico.BusinessObjects.AccessoryDetailsViewBO> Members
        public int Compare(Indico.BusinessObjects.AccessoryDetailsViewBO x, Indico.BusinessObjects.AccessoryDetailsViewBO y)
        {
            if (propertyToCompareName != null)
            {
                PropertyInfo p = typeof(Indico.BusinessObjects.AccessoryDetailsViewBO).GetProperty(propertyToCompareName);
                return compare(p, x, y);
            }
            else
            {
                PropertyInfo[] arrP = typeof(Indico.BusinessObjects.AccessoryDetailsViewBO).GetProperties();
                foreach (PropertyInfo p in arrP)
                {
                    int v = compare(p, x, y);
                    if (v != 0)
                        return v;
                }
                return 0;
            }
        }

        private int compare(PropertyInfo p, Indico.BusinessObjects.AccessoryDetailsViewBO x, Indico.BusinessObjects.AccessoryDetailsViewBO y)
        {
            object xVal = p.GetValue(x, null);
            object yVal = p.GetValue(y, null);

            if (xVal == null)
            {
                if (yVal == null)
                    return 0;
                else
                    return -1; // x is null, y is not, y is greater
            }
            else
            {
                if (y == null)
                    return 1; // x non null, y is null, x is greater
                else if (xVal is string)
                {
                    return StringComparer.OrdinalIgnoreCase.Compare(xVal, yVal);
                }
                else if (xVal is IComparable)
                {
                    return ((IComparable)xVal).CompareTo((IComparable)yVal);
                }
                else
                    throw new ArgumentException
                        ("is not string or valuetype that implements IComparable", "propertyToCompare");

            }
        }

        #endregion
    }
    #endregion
}
