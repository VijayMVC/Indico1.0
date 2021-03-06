// This file is generated by CodeSmith. Do not edit. All edits to this file will be lost. 
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic;
using System.Linq.Expressions;
using System.Reflection;
using System.Xml.Serialization;

using Indico.DAL;

//namespace Indico.BusinessObjects
namespace Indico.BusinessObjects
{
    /// <summary>
    /// 
    /// </summary>
    public partial class IndimanPriceRemarksBO : BusinessObject, IComparable
    {
        #region fields
        #region Scalar Fields
        private int id;
        private DateTime _createdDate = DateTime.MinValue;
        private int _creator;
        private int _price;
        private string _remarks = string.Empty;
        #endregion
        
        #region Foreign Key fields
        [NonSerialized][XmlIgnoreAttribute]
        private Indico.BusinessObjects.PriceBO _objPrice;
        #endregion
        
        #region Foreign Table Foreign Key fields
        #endregion
        
        #region Other fields
        
        private Indico.DAL.IndimanPriceRemarks _objDAL = null;
        private bool _doNotUpdateDALObject = false;
        
        #endregion
        
        #endregion
        
        #region Properties
        /// <summary>The Primary Key for this object</summary>
        public int ID
        {   get {return id;}
            set 
            {
                OnIDChanging(value);
                id = value;
                OnIDChanged();
            }
        }
        
        /// <summary>.</summary>
        public DateTime CreatedDate
        {   
            get {return _createdDate;}
            set 
            {
                OnCreatedDateChanging(value);
                _createdDate = value;
                if (!this._doNotUpdateDALObject && this.Context != null && this.ObjDAL != null){
                    this.ObjDAL.CreatedDate = value;
                }
                OnCreatedDateChanged();
            }
        }
        /// <summary>.</summary>
        public int Creator
        {   
            get {return _creator;}
            set 
            {
                OnCreatorChanging(value);
                _creator = value;
                if (!this._doNotUpdateDALObject && this.Context != null && this.ObjDAL != null){
                    this.ObjDAL.Creator = value;
                }
                OnCreatorChanged();
            }
        }
        /// <summary>.</summary>
        public int Price
        {   
            get {return _price;}
            set 
            {
                OnPriceChanging(value);
                _price = value;
                if (!this._doNotUpdateDALObject && this._context != null && this.ObjDAL != null && ((int)value != 0))
                {
                    this.ObjDAL.Price = (from o in this._context.Context.Price
                                           where o.ID == (int)value
                                           select o).ToList<Indico.DAL.Price>()[0];
                }
                else if (!this._doNotUpdateDALObject && this._context != null && this.ObjDAL != null && (int)value == 0)
                    this.ObjDAL.Price = null;
                OnPriceChanged();
            }
        }
        /// <summary>. The maximum length of this property is 512.</summary>
        public string Remarks
        {   
            get {return _remarks;}
            set 
            {
                OnRemarksChanging(value);
                _remarks = value;
                if (!this._doNotUpdateDALObject && this.Context != null && this.ObjDAL != null){
                    this.ObjDAL.Remarks = value;
                }
                OnRemarksChanged();
            }
        }
        
        internal Indico.DAL.IndimanPriceRemarks ObjDAL
        {
            get 
            {
                if (_objDAL == null && base._createDAL)
                {
                    _objDAL = this.SetDAL(this.Context.Context);
                    this.ObjDAL.PropertyChanged += new System.ComponentModel.PropertyChangedEventHandler(obj_PropertyChanged);
                }

                return _objDAL;
            }
            set 
            {
                _objDAL = value;
            }
        }
        
        #endregion
        
        #region Non-scalar Properties
        
        #region Foreign Key Objects
        ///<summary>The PriceBO object identified by the value of Price</summary>
        [XmlIgnoreAttribute]
        public Indico.BusinessObjects.PriceBO objPrice
        {
            get
            {
                if ( _price > 0 && _objPrice == null)
                {
                        if (this._context == null)
                        {
                            _objPrice = new Indico.BusinessObjects.PriceBO();
                        }
                        else
                        {
                            _objPrice = new Indico.BusinessObjects.PriceBO(ref this._context);
                        }
                        _objPrice.ID = _price;
                        _objPrice.GetObject(); 
                }
                return _objPrice;
            }
            set
            { 
                _objPrice = value;
                _price = _objPrice.ID;
            }
        }
        #endregion
        
        #region Foreign Object Foreign Key Collections
        #endregion
        
        #endregion
        
        #region Internal Constructors
        /// <summary>
        /// Creates an instance of the IndimanPriceRemarksBO class using the supplied Indico.DAL.IndimanPriceRemarks. 
        /// </summary>
        /// <param name="obj">a Indico.DAL.IndimanPriceRemarks whose properties will be used to initialise the IndimanPriceRemarksBO</param>
        internal IndimanPriceRemarksBO(Indico.DAL.IndimanPriceRemarks obj, ref IndicoContext context)
        {
            this._doNotUpdateDALObject = true;
            
            this.Context = context;
        
            // set the properties from the Indico.DAL.IndimanPriceRemarks 
            this.ID = obj.ID;
            
            this.CreatedDate = obj.CreatedDate;
            this.Creator = obj.Creator;
            this.Price = (obj.PriceReference.EntityKey != null && obj.PriceReference.EntityKey.EntityKeyValues.Count() > 0)
                ? (int)((System.Data.EntityKeyMember)obj.PriceReference.EntityKey.EntityKeyValues.GetValue(0)).Value
                : 0;
            this.Remarks = obj.Remarks;
            
            this._doNotUpdateDALObject = false;
        }
        #endregion
        
        #region Internal utility methods
        internal Indico.DAL.IndimanPriceRemarks SetDAL(IndicoEntities context)
        {
            this._doNotUpdateDALObject = true;
        
            // set the Indico.DAL.IndimanPriceRemarks properties
            Indico.DAL.IndimanPriceRemarks obj = new Indico.DAL.IndimanPriceRemarks();
            
            if (this.ID > 0)
            {
                obj = context.IndimanPriceRemarks.FirstOrDefault<IndimanPriceRemarks>(o => o.ID == this.ID);
            }
            
            obj.CreatedDate = this.CreatedDate;
            obj.Creator = this.Creator;
            obj.Remarks = this.Remarks;
            
            if (this.Price > 0) obj.Price = context.Price.FirstOrDefault(o => o.ID == this.Price);
            
            
            this._doNotUpdateDALObject = false;
            
            return obj;
        }
        
        internal void SetBO(System.Data.Objects.DataClasses.EntityObject eObj)
        {
            this._doNotUpdateDALObject = true;
            
            // Check the received type
            if (eObj.GetType() != typeof(Indico.DAL.IndimanPriceRemarks))
            {
                throw new FormatException("Received wrong parameter type...");
            }

            Indico.DAL.IndimanPriceRemarks obj = (Indico.DAL.IndimanPriceRemarks)eObj;
            
            // set the Indico.BusinessObjects.IndimanPriceRemarksBO properties
            this.ID = obj.ID;
            
            this.CreatedDate = obj.CreatedDate;
            this.Creator = obj.Creator;
            this.Remarks = obj.Remarks;
            
            this.Price = (obj.PriceReference.EntityKey != null && obj.PriceReference.EntityKey.EntityKeyValues.Count() > 0)
                ? (int)((System.Data.EntityKeyMember)obj.PriceReference.EntityKey.EntityKeyValues.GetValue(0)).Value
                : 0;
            
            this._doNotUpdateDALObject = false;
        }
        
        internal void SetBO(Indico.BusinessObjects.IndimanPriceRemarksBO obj)
        {
            this._doNotUpdateDALObject = true;
            
            // set this Indico.BusinessObjects.IndimanPriceRemarksBO properties
            this.ID = obj.ID;
            
            this.CreatedDate = obj.CreatedDate;
            this.Creator = obj.Creator;
            this.Price = obj.Price;
            this.Remarks = obj.Remarks;
            
            this._doNotUpdateDALObject = false;
        }
        
        internal List<Indico.BusinessObjects.IndimanPriceRemarksBO> IQueryableToList(IQueryable<Indico.DAL.IndimanPriceRemarks> oQuery)
        {
            List<Indico.DAL.IndimanPriceRemarks> oList = oQuery.ToList();
            List<Indico.BusinessObjects.IndimanPriceRemarksBO> rList = new List<Indico.BusinessObjects.IndimanPriceRemarksBO>(oList.Count);
            foreach (Indico.DAL.IndimanPriceRemarks o in oList)
            {
                Indico.BusinessObjects.IndimanPriceRemarksBO obj = new Indico.BusinessObjects.IndimanPriceRemarksBO(o, ref this._context);
                rList.Add(obj);
            }
            return rList;
        }
        
        internal List<Indico.BusinessObjects.IndimanPriceRemarksBO> ToList(IEnumerable<Indico.DAL.IndimanPriceRemarks> oQuery)
        {
            List<Indico.DAL.IndimanPriceRemarks> oList = oQuery.ToList();
            List<Indico.BusinessObjects.IndimanPriceRemarksBO> rList = new List<Indico.BusinessObjects.IndimanPriceRemarksBO>(oList.Count);
            foreach (Indico.DAL.IndimanPriceRemarks o in oList)
            {
                Indico.BusinessObjects.IndimanPriceRemarksBO obj = new Indico.BusinessObjects.IndimanPriceRemarksBO(o, ref this._context);
                rList.Add(obj);
            }
            return rList;
        }
        
        internal static List<Indico.DAL.IndimanPriceRemarks> ToEntityList(List<IndimanPriceRemarksBO> bos, IndicoEntities context)
        {
            // build a List of IndimanPriceRemarks entities from the business objects
            List<Int32> ids = (from o in bos
                                   select o.ID).ToList<Int32>();

            return (context.IndimanPriceRemarks.Count() == 0) ? new List<Indico.DAL.IndimanPriceRemarks>() : (context.IndimanPriceRemarks.Where(BuildContainsExpression<IndimanPriceRemarks, int>(e => e.ID, ids)))
                .ToList<Indico.DAL.IndimanPriceRemarks>();
        }
        
        internal static System.Data.Objects.DataClasses.EntityCollection<Indico.DAL.IndimanPriceRemarks> ToEntityCollection(List<IndimanPriceRemarksBO> bos, IndicoEntities context)
        {
            // build an EntityCollection of IndimanPriceRemarks entities from the business objects
            List<Int32> ids = (from o in bos
                               select o.ID).ToList<Int32>();

            List<Indico.DAL.IndimanPriceRemarks> el = (context.IndimanPriceRemarks.Count() == 0) ? new List<Indico.DAL.IndimanPriceRemarks>() : 
                context.IndimanPriceRemarks.Where(BuildContainsExpression<IndimanPriceRemarks, int>(e => e.ID, ids))
                .ToList<Indico.DAL.IndimanPriceRemarks>();
                
            System.Data.Objects.DataClasses.EntityCollection<Indico.DAL.IndimanPriceRemarks> ec 
                = new System.Data.Objects.DataClasses.EntityCollection<Indico.DAL.IndimanPriceRemarks>();
                
            foreach (Indico.DAL.IndimanPriceRemarks r in el) 
            {
                ec.Add(r);
            }
            return ec;
        }

        internal Indico.DAL.IndimanPriceRemarks ToEntity(IndicoEntities context)
        {
            return (from o in context.IndimanPriceRemarks
                    where o.ID == this.ID
                    select o).FirstOrDefault();
        }
        #endregion
        
        #region BusinessObject methods
        
        #region Add Object
        
        public void Add()
        {
            if (this.Context != null)
            {
                this.Context.Context.AddToIndimanPriceRemarks(this.ObjDAL);
            }
            else
            {
                IndicoContext objContext = new IndicoContext();
                Indico.DAL.IndimanPriceRemarks obj = this.SetDAL(objContext.Context);
                objContext.Context.AddToIndimanPriceRemarks(obj);
                objContext.SaveChanges();
                objContext.Dispose(); 
            }
        }
        
        #endregion
        
        #region Delete Object
        
        public void Delete()
        {
            if (this.Context != null)
            {
                if (this.ObjDAL != null && this.ObjDAL.EntityKey != null)
                {
                    if (this.ObjDAL.EntityState == System.Data.EntityState.Detached)
                    {
                        this.Context.Context.Attach(this.ObjDAL);
                        this.Context.Context.DeleteObject(this.ObjDAL);
                    }
                    else
                    {
                        this.Context.Context.DeleteObject(this.ObjDAL);
                    }
                }
                else
                {
                    Indico.DAL.IndimanPriceRemarks obj = this.SetDAL(this.Context.Context);
                    this.Context.Context.DeleteObject(obj);
                }
            }
            else
            {
                IndicoContext objContext = new IndicoContext();
                Indico.DAL.IndimanPriceRemarks obj = this.SetDAL(objContext.Context);
                this.Context.Context.DeleteObject(obj);
                objContext.Context.SaveChanges();
                objContext.Dispose();
            }
        }
        
        #endregion
        
        #region Get Single Object
        
        public bool GetObject()
        {
            return GetObject(true);
        }
        public bool GetObject(bool blnCache)
        {
            Indico.BusinessObjects.IndimanPriceRemarksBO data = null;
            
            if (blnCache)
            {
                data = this.GetFromCache(this.ID) as Indico.BusinessObjects.IndimanPriceRemarksBO; 
            }

            if (data != null)
            {
                SetBO(data);
            }
            else
            {
                try
                {
                    IndicoEntities context = (this.Context != null) ? this.Context.Context : new IndicoEntities();
                    IQueryable<Indico.DAL.IndimanPriceRemarks> oQuery =
                        from o in context.IndimanPriceRemarks
                        where o.ID == this.ID
                        select o;

                    List<Indico.DAL.IndimanPriceRemarks> oList = oQuery.ToList();
                    if (oList.Count != 1)
                        return false;
                    else
                    {
                        SetBO(oList[0]);
                        this.Cache();
                    }
                    
                    if (this.Context == null)
                    {
                        context.Dispose();
                    }
                }
                catch (System.Exception e)
                {
                    throw new IndicoException(String.Format(System.Globalization.CultureInfo.InvariantCulture, ResourceManager.GetString("Could not Retrieve a {0} from the data store", System.Globalization.CultureInfo.CurrentCulture), this.ToString()), e, IndicoException.Severities.USER, IndicoException.ERRNO.INT_ERR_BO_SELECT_FAIL);
                }
            }
            return true;
        }
        #endregion
        
        #region GetAllObject
        public List<Indico.BusinessObjects.IndimanPriceRemarksBO> GetAllObject()
        {
            return GetAllObject(0, 0);
        }
        public List<Indico.BusinessObjects.IndimanPriceRemarksBO> GetAllObject(int maximumRows)
        {
            return GetAllObject(maximumRows, 0);
        }
        public List<Indico.BusinessObjects.IndimanPriceRemarksBO> GetAllObject(int maximumRows, int startIndex)
        {
            return GetAllObject(maximumRows, startIndex, null, false);
        }
        public List<Indico.BusinessObjects.IndimanPriceRemarksBO> GetAllObject(int maximumRows, int startIndex, string sortExpression, bool sortDescending)
        {
            IndicoEntities context = new IndicoEntities();
            IQueryable<Indico.DAL.IndimanPriceRemarks> oQuery =
                (from o in context.IndimanPriceRemarks
                 orderby o.ID
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
                oQuery = oQuery.OrderBy(obj => obj.ID).Skip(startIndex).Take((maximumRows == 0) ? Int32.MaxValue : maximumRows);

            List<Indico.BusinessObjects.IndimanPriceRemarksBO> indimanpriceremarkss = IQueryableToList(oQuery);
            context.Dispose();
            return indimanpriceremarkss;
        }
        #endregion
        
        #region SearchObjects
        public List<Indico.BusinessObjects.IndimanPriceRemarksBO> SearchObjects()
        {
            return SearchObjects(0,0);
        }
        public List<Indico.BusinessObjects.IndimanPriceRemarksBO> SearchObjects(int maximumRows)
        {
            return SearchObjects(maximumRows, 0);
        }
        public List<Indico.BusinessObjects.IndimanPriceRemarksBO> SearchObjects(int maximumRows, int startIndex)
        {
            return SearchObjects(maximumRows, startIndex, null, false);
        }
        public List<Indico.BusinessObjects.IndimanPriceRemarksBO> SearchObjects(int maximumRows, int startIndex, string sortExpression, bool sortDescending)
        {
            IndicoEntities context = (this.Context != null) ? this.Context.Context : new IndicoEntities();
            IQueryable<Indico.DAL.IndimanPriceRemarks> oQuery =
                (from o in context.IndimanPriceRemarks
                 where
                    (this.ID == 0 || this.ID == o.ID) &&
                    (this.Price == 0 || this.Price == o.Price.ID) &&
                    (this.Remarks == string.Empty || this.Remarks == o.Remarks) &&
                    (this.Creator == 0 || this.Creator == o.Creator) &&
                    (this.CreatedDate == DateTime.MinValue || this.CreatedDate == o.CreatedDate) 
                 orderby o.ID
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
                oQuery = oQuery.OrderBy(obj => obj.ID).Skip(startIndex).Take((maximumRows == 0) ? Int32.MaxValue : maximumRows);

            List<Indico.BusinessObjects.IndimanPriceRemarksBO> indimanpriceremarkss = IQueryableToList(oQuery);
            
            if (this.Context == null)
            {
                context.Dispose();
            }
            
            return indimanpriceremarkss;
        }
        
        public int SearchObjectsCount()
        {
            IndicoEntities context = (this.Context != null) ? this.Context.Context : new IndicoEntities();
            return (from o in context.IndimanPriceRemarks
                 where
                    (this.ID == 0 || this.ID == o.ID) &&
                    (this.Price == 0 || this.Price == o.Price.ID) &&
                    (this.Remarks == string.Empty || this.Remarks == o.Remarks) &&
                    (this.Creator == 0 || this.Creator == o.Creator) &&
                    (this.CreatedDate == DateTime.MinValue || this.CreatedDate == o.CreatedDate) 
                 orderby o.ID
                 select o).Count();
        }
        #endregion
        
        #region SearchObjectsLikeAnd
        public List<Indico.BusinessObjects.IndimanPriceRemarksBO> SearchLikeAndObjects()
        {
            return SearchLikeAndObjects(0);
        }
        public List<Indico.BusinessObjects.IndimanPriceRemarksBO> SearchLikeAndObjects(int maximumRows)
        {
            return SearchLikeAndObjects(maximumRows, 0);
        }
        public List<Indico.BusinessObjects.IndimanPriceRemarksBO> SearchLikeAndObjects(int maximumRows, int startIndex)
        {
            return SearchLikeAndObjects(maximumRows, startIndex, null, false);
        }
        public List<Indico.BusinessObjects.IndimanPriceRemarksBO> SearchLikeAndObjects(int maximumRows, int startIndex, string sortExpression, bool sortDescending)
        {
            IndicoEntities context = (this.Context != null) ? this.Context.Context : new IndicoEntities();
            IQueryable<Indico.DAL.IndimanPriceRemarks> oQuery =
                (from o in context.IndimanPriceRemarks
                 where
                    (this.ID == 0 || o.ID == this.ID) &&
                    (this.Price == 0 || o.Price.ID == this.Price) &&
                    (this.Remarks == string.Empty || o.Remarks.Contains(this.Remarks)) &&
                    (this.Creator == 0 || o.Creator == this.Creator) &&
                    (this.CreatedDate == DateTime.MinValue || o.CreatedDate == this.CreatedDate) 
                 orderby o.ID
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
                oQuery = oQuery.OrderBy(obj => obj.ID).Skip(startIndex).Take((maximumRows == 0) ? Int32.MaxValue : maximumRows);

            List<Indico.BusinessObjects.IndimanPriceRemarksBO> indimanpriceremarkss = IQueryableToList(oQuery);
            if (this.Context == null)
            {
                context.Dispose();
            }
            
            return indimanpriceremarkss;
        }
        
        public int SearchLikeAndObjectsCount()
        {
            IndicoEntities context = (this.Context != null) ? this.Context.Context : new IndicoEntities();
            return (from o in context.IndimanPriceRemarks
                 where
                    (this.ID == 0 || o.ID == this.ID) &&
                    (this.Price == 0 || o.Price.ID == this.Price) &&
                    (this.Remarks == string.Empty || o.Remarks.Contains(this.Remarks)) &&
                    (this.Creator == 0 || o.Creator == this.Creator) &&
                    (this.CreatedDate == DateTime.MinValue || o.CreatedDate == this.CreatedDate) 
                 orderby o.ID
                 select o).Count();
            
        }
        #endregion
        
        #region SearchObjectsLikeOr
        public List<Indico.BusinessObjects.IndimanPriceRemarksBO> SearchLikeOrObjects()
        {
            return SearchLikeOrObjects(0);
        }
        public List<Indico.BusinessObjects.IndimanPriceRemarksBO> SearchLikeOrObjects(int maximumRows)
        {
            return SearchLikeOrObjects(maximumRows, 0);
        }
        public List<Indico.BusinessObjects.IndimanPriceRemarksBO> SearchLikeOrObjects(int maximumRows, int startIndex)
        {
            return SearchLikeOrObjects(maximumRows, startIndex, null, false);
        }
        public List<Indico.BusinessObjects.IndimanPriceRemarksBO> SearchLikeOrObjects(int maximumRows, int startIndex, string sortExpression, bool sortDescending)
        {
            IndicoEntities context = (this.Context != null) ? this.Context.Context : new IndicoEntities();
            IQueryable<Indico.DAL.IndimanPriceRemarks> oQuery =
                (from o in context.IndimanPriceRemarks
                 where
                    (this.ID == 0 || this.ID == o.ID) && 
                    (this.Price == 0 || this.Price == o.Price.ID) && 
                    (this.Creator == 0 || this.Creator == o.Creator) && 
                    (this.CreatedDate == DateTime.MinValue || this.CreatedDate == o.CreatedDate) && 
                    ((o.Remarks.Contains(this.Remarks)) ||
                    (this.Remarks == null ))
                 orderby o.ID
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
                oQuery = oQuery.OrderBy(obj => obj.ID).Skip(startIndex).Take((maximumRows == 0) ? Int32.MaxValue : maximumRows);

            List<Indico.BusinessObjects.IndimanPriceRemarksBO> indimanpriceremarkss = IQueryableToList(oQuery);
            if (this.Context == null)
            {
                context.Dispose();
            }
            
            return indimanpriceremarkss;
        }
        
        public int SearchLikeOrObjectsCount()
        {
            IndicoEntities context = (this.Context != null) ? this.Context.Context : new IndicoEntities();
            return (from o in context.IndimanPriceRemarks
                 where
                    (this.ID == 0 || this.ID == o.ID) && 
                    (this.Price == 0 || this.Price == o.Price.ID) && 
                    (this.Creator == 0 || this.Creator == o.Creator) && 
                    (this.CreatedDate == DateTime.MinValue || this.CreatedDate == o.CreatedDate) && 
                    ((o.Remarks.Contains(this.Remarks)) ||
                    (this.Remarks == null ))
                 orderby o.ID
                 select o).Count();
            
        }
        #endregion
        
        #region Serialization methods
        /// <summary>
        /// Serializes the Indico.BusinessObjects.IndimanPriceRemarksBO to an XML representation
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
        /// Deserializes Indico.BusinessObjects.IndimanPriceRemarksBO object from an XML representation
        /// </summary>
        /// <param name="strXML">a XML string serialized representation</param>
        public Indico.BusinessObjects.IndimanPriceRemarksBO DeserializeObject(string strXML)
        {
            Indico.BusinessObjects.IndimanPriceRemarksBO objTemp = null;
            System.Xml.XmlDocument objXML = new System.Xml.XmlDocument();

            objXML.LoadXml(strXML);
            System.Text.Encoding encoding = System.Text.Encoding.UTF8;

            System.IO.MemoryStream objStream = new System.IO.MemoryStream();
            byte[] b = encoding.GetBytes(objXML.OuterXml);

            objStream.Write(b, 0, (int)b.Length);
            objStream.Position = 0;
            System.Xml.Serialization.XmlSerializer x = new System.Xml.Serialization.XmlSerializer(this.GetType());

            objTemp = (Indico.BusinessObjects.IndimanPriceRemarksBO)x.Deserialize(objStream);
            objStream.Close();
            return objTemp;
        }

        /// <summary>
        /// Returns a simple XML representation of Indico.BusinessObjects.IndimanPriceRemarksBO object in an XmlElement
        /// </summary>
        /// <returns>An XML snippet representing the object</returns>
        public string ToXmlString()
        {
            // MW TODO - implement this better.
            return SerializeObject();
        }
        #endregion
        
        #region OnPropertyChange Methods
        partial void OnIDChanged()
        {
            OnIndimanPriceRemarksBOIDChanged();
        }
        
        partial void OnIDChanging(int value)
        {
            if (value < 0)
            {
                throw new Exception(String.Format("IndimanPriceRemarksBO.ID must be more than or equal to 0. The supplied value was {0}.", value));
            }
            OnIndimanPriceRemarksBOIDChanging(value);
        }
        partial void OnIDChanged();
        partial void OnIDChanging(int value);
        partial void OnIndimanPriceRemarksBOIDChanged();
        partial void OnIndimanPriceRemarksBOIDChanging(int value);
        
        partial void OnPriceChanged()
        {
            OnIndimanPriceRemarksBOPriceChanged();
        }
        
        partial void OnPriceChanging(int value)
        {
            if (value < 0)
            {
                throw new Exception(String.Format("IndimanPriceRemarksBO.Price must be more than or equal to 0. The supplied value was {0}.", value));
            }
            OnIndimanPriceRemarksBOPriceChanging(value);
        }
        partial void OnPriceChanged();
        partial void OnPriceChanging(int value);
        partial void OnIndimanPriceRemarksBOPriceChanged();
        partial void OnIndimanPriceRemarksBOPriceChanging(int value);
        
        partial void OnRemarksChanged()
        {
            OnIndimanPriceRemarksBORemarksChanged();
        }
        
        partial void OnRemarksChanging(string value)
        {
            if (value != null && value.Length > 512)
            {
                throw new Exception(String.Format("IndimanPriceRemarksBO.Remarks has a maximum length of 512. The supplied value \"{0}\" has a length of {1}", value, value.Length));
            }
            OnIndimanPriceRemarksBORemarksChanging(value);
        }
        partial void OnRemarksChanged();
        partial void OnRemarksChanging(string value);
        partial void OnIndimanPriceRemarksBORemarksChanged();
        partial void OnIndimanPriceRemarksBORemarksChanging(string value);
        
        partial void OnCreatorChanged()
        {
            OnIndimanPriceRemarksBOCreatorChanged();
        }
        
        partial void OnCreatorChanging(int value)
        {
            OnIndimanPriceRemarksBOCreatorChanging(value);
        }
        partial void OnCreatorChanged();
        partial void OnCreatorChanging(int value);
        partial void OnIndimanPriceRemarksBOCreatorChanged();
        partial void OnIndimanPriceRemarksBOCreatorChanging(int value);
        
        partial void OnCreatedDateChanged()
        {
            OnIndimanPriceRemarksBOCreatedDateChanged();
        }
        
        partial void OnCreatedDateChanging(DateTime value)
        {
            OnIndimanPriceRemarksBOCreatedDateChanging(value);
        }
        partial void OnCreatedDateChanged();
        partial void OnCreatedDateChanging(DateTime value);
        partial void OnIndimanPriceRemarksBOCreatedDateChanged();
        partial void OnIndimanPriceRemarksBOCreatedDateChanging(DateTime value);
        
        #endregion
        
        #region IComparable Members

        public int CompareTo(object obj)
        {
            if (!(obj is Indico.BusinessObjects.IndimanPriceRemarksBO))
                return 1;
            Indico.BusinessObjects.IndimanPriceRemarksBOComparer c = new Indico.BusinessObjects.IndimanPriceRemarksBOComparer();
            return c.Compare(this, obj as Indico.BusinessObjects.IndimanPriceRemarksBO);
        }

        #endregion
        #endregion
        
        #region Events
        
        void obj_PropertyChanged(object sender, System.ComponentModel.PropertyChangedEventArgs e)
        {
            if (e.PropertyName == "ID")
            {
                // reload me
                this.SetBO((Indico.DAL.IndimanPriceRemarks)sender);
            }
        }
        
        void Context_OnSendBeforeChanges(object sender, EventArgs e)
        {        
        }
        
        void Context_OnSendAfterChanges(object sender, EventArgs e)
        {   
            if (this.ID > 0)
            {
                this.Cache();
            }
        }

        #endregion
    }
    
    #region IndimanPriceRemarksBOComparer
    public class IndimanPriceRemarksBOComparer : IComparer<Indico.BusinessObjects.IndimanPriceRemarksBO>
    {
        private string propertyToCompareName;
        public IndimanPriceRemarksBOComparer(string propertyToCompare)
        {
            PropertyInfo p = typeof(Indico.BusinessObjects.IndimanPriceRemarksBO).GetProperty(propertyToCompare);
            if (p == null)
                throw new ArgumentException("is not a public property of Indico.BusinessObjects.IndimanPriceRemarksBO", "propertyToCompare");
            this.propertyToCompareName = propertyToCompare;
        }
        
        public IndimanPriceRemarksBOComparer()
        {
        
        }

        #region IComparer<Indico.BusinessObjects.IndimanPriceRemarksBO> Members
        public int Compare(Indico.BusinessObjects.IndimanPriceRemarksBO x, Indico.BusinessObjects.IndimanPriceRemarksBO y)
        {
            if (propertyToCompareName != null)
            {
                PropertyInfo p = typeof(Indico.BusinessObjects.IndimanPriceRemarksBO).GetProperty(propertyToCompareName);
                return compare(p, x, y);
            }
            else
            {
                PropertyInfo[] arrP = typeof(Indico.BusinessObjects.IndimanPriceRemarksBO).GetProperties();
                foreach (PropertyInfo p in arrP)
                {
                    int v = compare(p, x, y);
                    if (v != 0)
                        return v;
                }
                return 0;
            }
        }

        private int compare(PropertyInfo p, Indico.BusinessObjects.IndimanPriceRemarksBO x, Indico.BusinessObjects.IndimanPriceRemarksBO y)
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
