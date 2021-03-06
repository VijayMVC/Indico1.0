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
    public partial class QuoteChangeEmailListBO : BusinessObject, IComparable
    {
        #region fields
        #region Scalar Fields
        private int id;
        private bool _isCC;
        private int? _user;
        #endregion
        
        #region Foreign Key fields
        [NonSerialized][XmlIgnoreAttribute]
        private Indico.BusinessObjects.UserBO _objUser;
        #endregion
        
        #region Foreign Table Foreign Key fields
        #endregion
        
        #region Other fields
        
        private Indico.DAL.QuoteChangeEmailList _objDAL = null;
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
        public bool IsCC
        {   
            get {return _isCC;}
            set 
            {
                OnIsCCChanging(value);
                _isCC = value;
                if (!this._doNotUpdateDALObject && this.Context != null && this.ObjDAL != null){
                    this.ObjDAL.IsCC = value;
                }
                OnIsCCChanged();
            }
        }
        /// <summary>.</summary>
        public int? User
        {   
            get {return _user;}
            set 
            {
                OnUserChanging(value);
                _user = value;
                if (!this._doNotUpdateDALObject && this._context != null && this.ObjDAL != null && (value != null) && ((int)value != 0))
                {
                    this.ObjDAL.User = (from o in this._context.Context.User
                                           where o.ID == (int)value
                                           select o).ToList<Indico.DAL.User>()[0];
                }
                else if (value == null || !this._doNotUpdateDALObject && this._context != null && this.ObjDAL != null && (int)value == 0)
                    this.ObjDAL.User = null;
                OnUserChanged();
            }
        }
        
        internal Indico.DAL.QuoteChangeEmailList ObjDAL
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
        ///<summary>The UserBO object identified by the value of User</summary>
        [XmlIgnoreAttribute]
        public Indico.BusinessObjects.UserBO objUser
        {
            get
            {
                if (_user != null && _user > 0 && _objUser == null)
                {
                        if (this._context == null)
                        {
                            _objUser = new Indico.BusinessObjects.UserBO();
                        }
                        else
                        {
                            _objUser = new Indico.BusinessObjects.UserBO(ref this._context);
                        }
                        _objUser.ID = Convert.ToInt32(_user);
                        _objUser.GetObject(); 
                }
                return _objUser;
            }
            set
            { 
                _objUser = value;
                _user = _objUser.ID;
            }
        }
        #endregion
        
        #region Foreign Object Foreign Key Collections
        #endregion
        
        #endregion
        
        #region Internal Constructors
        /// <summary>
        /// Creates an instance of the QuoteChangeEmailListBO class using the supplied Indico.DAL.QuoteChangeEmailList. 
        /// </summary>
        /// <param name="obj">a Indico.DAL.QuoteChangeEmailList whose properties will be used to initialise the QuoteChangeEmailListBO</param>
        internal QuoteChangeEmailListBO(Indico.DAL.QuoteChangeEmailList obj, ref IndicoContext context)
        {
            this._doNotUpdateDALObject = true;
            
            this.Context = context;
        
            // set the properties from the Indico.DAL.QuoteChangeEmailList 
            this.ID = obj.ID;
            
            this.IsCC = obj.IsCC;
            this.User = (obj.UserReference.EntityKey != null && obj.UserReference.EntityKey.EntityKeyValues.Count() > 0)
                ? (int)((System.Data.EntityKeyMember)obj.UserReference.EntityKey.EntityKeyValues.GetValue(0)).Value
                : 0;
            
            this._doNotUpdateDALObject = false;
        }
        #endregion
        
        #region Internal utility methods
        internal Indico.DAL.QuoteChangeEmailList SetDAL(IndicoEntities context)
        {
            this._doNotUpdateDALObject = true;
        
            // set the Indico.DAL.QuoteChangeEmailList properties
            Indico.DAL.QuoteChangeEmailList obj = new Indico.DAL.QuoteChangeEmailList();
            
            if (this.ID > 0)
            {
                obj = context.QuoteChangeEmailList.FirstOrDefault<QuoteChangeEmailList>(o => o.ID == this.ID);
            }
            
            obj.IsCC = this.IsCC;
            
            if (this.User != null && this.User > 0) obj.User = context.User.FirstOrDefault(o => o.ID == this.User);
            
            
            this._doNotUpdateDALObject = false;
            
            return obj;
        }
        
        internal void SetBO(System.Data.Objects.DataClasses.EntityObject eObj)
        {
            this._doNotUpdateDALObject = true;
            
            // Check the received type
            if (eObj.GetType() != typeof(Indico.DAL.QuoteChangeEmailList))
            {
                throw new FormatException("Received wrong parameter type...");
            }

            Indico.DAL.QuoteChangeEmailList obj = (Indico.DAL.QuoteChangeEmailList)eObj;
            
            // set the Indico.BusinessObjects.QuoteChangeEmailListBO properties
            this.ID = obj.ID;
            
            this.IsCC = obj.IsCC;
            
            this.User = (obj.UserReference.EntityKey != null && obj.UserReference.EntityKey.EntityKeyValues.Count() > 0)
                ? (int)((System.Data.EntityKeyMember)obj.UserReference.EntityKey.EntityKeyValues.GetValue(0)).Value
                : 0;
            
            this._doNotUpdateDALObject = false;
        }
        
        internal void SetBO(Indico.BusinessObjects.QuoteChangeEmailListBO obj)
        {
            this._doNotUpdateDALObject = true;
            
            // set this Indico.BusinessObjects.QuoteChangeEmailListBO properties
            this.ID = obj.ID;
            
            this.IsCC = obj.IsCC;
            this.User = obj.User;
            
            this._doNotUpdateDALObject = false;
        }
        
        internal List<Indico.BusinessObjects.QuoteChangeEmailListBO> IQueryableToList(IQueryable<Indico.DAL.QuoteChangeEmailList> oQuery)
        {
            List<Indico.DAL.QuoteChangeEmailList> oList = oQuery.ToList();
            List<Indico.BusinessObjects.QuoteChangeEmailListBO> rList = new List<Indico.BusinessObjects.QuoteChangeEmailListBO>(oList.Count);
            foreach (Indico.DAL.QuoteChangeEmailList o in oList)
            {
                Indico.BusinessObjects.QuoteChangeEmailListBO obj = new Indico.BusinessObjects.QuoteChangeEmailListBO(o, ref this._context);
                rList.Add(obj);
            }
            return rList;
        }
        
        internal List<Indico.BusinessObjects.QuoteChangeEmailListBO> ToList(IEnumerable<Indico.DAL.QuoteChangeEmailList> oQuery)
        {
            List<Indico.DAL.QuoteChangeEmailList> oList = oQuery.ToList();
            List<Indico.BusinessObjects.QuoteChangeEmailListBO> rList = new List<Indico.BusinessObjects.QuoteChangeEmailListBO>(oList.Count);
            foreach (Indico.DAL.QuoteChangeEmailList o in oList)
            {
                Indico.BusinessObjects.QuoteChangeEmailListBO obj = new Indico.BusinessObjects.QuoteChangeEmailListBO(o, ref this._context);
                rList.Add(obj);
            }
            return rList;
        }
        
        internal static List<Indico.DAL.QuoteChangeEmailList> ToEntityList(List<QuoteChangeEmailListBO> bos, IndicoEntities context)
        {
            // build a List of QuoteChangeEmailList entities from the business objects
            List<Int32> ids = (from o in bos
                                   select o.ID).ToList<Int32>();

            return (context.QuoteChangeEmailList.Count() == 0) ? new List<Indico.DAL.QuoteChangeEmailList>() : (context.QuoteChangeEmailList.Where(BuildContainsExpression<QuoteChangeEmailList, int>(e => e.ID, ids)))
                .ToList<Indico.DAL.QuoteChangeEmailList>();
        }
        
        internal static System.Data.Objects.DataClasses.EntityCollection<Indico.DAL.QuoteChangeEmailList> ToEntityCollection(List<QuoteChangeEmailListBO> bos, IndicoEntities context)
        {
            // build an EntityCollection of QuoteChangeEmailList entities from the business objects
            List<Int32> ids = (from o in bos
                               select o.ID).ToList<Int32>();

            List<Indico.DAL.QuoteChangeEmailList> el = (context.QuoteChangeEmailList.Count() == 0) ? new List<Indico.DAL.QuoteChangeEmailList>() : 
                context.QuoteChangeEmailList.Where(BuildContainsExpression<QuoteChangeEmailList, int>(e => e.ID, ids))
                .ToList<Indico.DAL.QuoteChangeEmailList>();
                
            System.Data.Objects.DataClasses.EntityCollection<Indico.DAL.QuoteChangeEmailList> ec 
                = new System.Data.Objects.DataClasses.EntityCollection<Indico.DAL.QuoteChangeEmailList>();
                
            foreach (Indico.DAL.QuoteChangeEmailList r in el) 
            {
                ec.Add(r);
            }
            return ec;
        }

        internal Indico.DAL.QuoteChangeEmailList ToEntity(IndicoEntities context)
        {
            return (from o in context.QuoteChangeEmailList
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
                this.Context.Context.AddToQuoteChangeEmailList(this.ObjDAL);
            }
            else
            {
                IndicoContext objContext = new IndicoContext();
                Indico.DAL.QuoteChangeEmailList obj = this.SetDAL(objContext.Context);
                objContext.Context.AddToQuoteChangeEmailList(obj);
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
                    Indico.DAL.QuoteChangeEmailList obj = this.SetDAL(this.Context.Context);
                    this.Context.Context.DeleteObject(obj);
                }
            }
            else
            {
                IndicoContext objContext = new IndicoContext();
                Indico.DAL.QuoteChangeEmailList obj = this.SetDAL(objContext.Context);
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
            Indico.BusinessObjects.QuoteChangeEmailListBO data = null;
            
            if (blnCache)
            {
                data = this.GetFromCache(this.ID) as Indico.BusinessObjects.QuoteChangeEmailListBO; 
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
                    IQueryable<Indico.DAL.QuoteChangeEmailList> oQuery =
                        from o in context.QuoteChangeEmailList
                        where o.ID == this.ID
                        select o;

                    List<Indico.DAL.QuoteChangeEmailList> oList = oQuery.ToList();
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
        public List<Indico.BusinessObjects.QuoteChangeEmailListBO> GetAllObject()
        {
            return GetAllObject(0, 0);
        }
        public List<Indico.BusinessObjects.QuoteChangeEmailListBO> GetAllObject(int maximumRows)
        {
            return GetAllObject(maximumRows, 0);
        }
        public List<Indico.BusinessObjects.QuoteChangeEmailListBO> GetAllObject(int maximumRows, int startIndex)
        {
            return GetAllObject(maximumRows, startIndex, null, false);
        }
        public List<Indico.BusinessObjects.QuoteChangeEmailListBO> GetAllObject(int maximumRows, int startIndex, string sortExpression, bool sortDescending)
        {
            IndicoEntities context = new IndicoEntities();
            IQueryable<Indico.DAL.QuoteChangeEmailList> oQuery =
                (from o in context.QuoteChangeEmailList
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

            List<Indico.BusinessObjects.QuoteChangeEmailListBO> quotechangeemaillists = IQueryableToList(oQuery);
            context.Dispose();
            return quotechangeemaillists;
        }
        #endregion
        
        #region SearchObjects
        public List<Indico.BusinessObjects.QuoteChangeEmailListBO> SearchObjects()
        {
            return SearchObjects(0,0);
        }
        public List<Indico.BusinessObjects.QuoteChangeEmailListBO> SearchObjects(int maximumRows)
        {
            return SearchObjects(maximumRows, 0);
        }
        public List<Indico.BusinessObjects.QuoteChangeEmailListBO> SearchObjects(int maximumRows, int startIndex)
        {
            return SearchObjects(maximumRows, startIndex, null, false);
        }
        public List<Indico.BusinessObjects.QuoteChangeEmailListBO> SearchObjects(int maximumRows, int startIndex, string sortExpression, bool sortDescending)
        {
            IndicoEntities context = (this.Context != null) ? this.Context.Context : new IndicoEntities();
            IQueryable<Indico.DAL.QuoteChangeEmailList> oQuery =
                (from o in context.QuoteChangeEmailList
                 where
                    (this.ID == 0 || this.ID == o.ID) &&
                    (this.User == null || this.User == o.User.ID) &&
                    (this.IsCC == false || this.IsCC == o.IsCC) 
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

            List<Indico.BusinessObjects.QuoteChangeEmailListBO> quotechangeemaillists = IQueryableToList(oQuery);
            
            if (this.Context == null)
            {
                context.Dispose();
            }
            
            return quotechangeemaillists;
        }
        
        public int SearchObjectsCount()
        {
            IndicoEntities context = (this.Context != null) ? this.Context.Context : new IndicoEntities();
            return (from o in context.QuoteChangeEmailList
                 where
                    (this.ID == 0 || this.ID == o.ID) &&
                    (this.User == null || this.User == o.User.ID) &&
                    (this.IsCC == false || this.IsCC == o.IsCC) 
                 orderby o.ID
                 select o).Count();
        }
        #endregion
        
        #region SearchObjectsLikeAnd
        public List<Indico.BusinessObjects.QuoteChangeEmailListBO> SearchLikeAndObjects()
        {
            return SearchLikeAndObjects(0);
        }
        public List<Indico.BusinessObjects.QuoteChangeEmailListBO> SearchLikeAndObjects(int maximumRows)
        {
            return SearchLikeAndObjects(maximumRows, 0);
        }
        public List<Indico.BusinessObjects.QuoteChangeEmailListBO> SearchLikeAndObjects(int maximumRows, int startIndex)
        {
            return SearchLikeAndObjects(maximumRows, startIndex, null, false);
        }
        public List<Indico.BusinessObjects.QuoteChangeEmailListBO> SearchLikeAndObjects(int maximumRows, int startIndex, string sortExpression, bool sortDescending)
        {
            IndicoEntities context = (this.Context != null) ? this.Context.Context : new IndicoEntities();
            IQueryable<Indico.DAL.QuoteChangeEmailList> oQuery =
                (from o in context.QuoteChangeEmailList
                 where
                    (this.ID == 0 || o.ID == this.ID) &&
                    (this.User == null || o.User.ID == this.User) &&
                    (this.IsCC == false || o.IsCC == this.IsCC) 
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

            List<Indico.BusinessObjects.QuoteChangeEmailListBO> quotechangeemaillists = IQueryableToList(oQuery);
            if (this.Context == null)
            {
                context.Dispose();
            }
            
            return quotechangeemaillists;
        }
        
        public int SearchLikeAndObjectsCount()
        {
            IndicoEntities context = (this.Context != null) ? this.Context.Context : new IndicoEntities();
            return (from o in context.QuoteChangeEmailList
                 where
                    (this.ID == 0 || o.ID == this.ID) &&
                    (this.User == null || o.User.ID == this.User) &&
                    (this.IsCC == false || o.IsCC == this.IsCC) 
                 orderby o.ID
                 select o).Count();
            
        }
        #endregion
        
        #region SearchObjectsLikeOr
        public List<Indico.BusinessObjects.QuoteChangeEmailListBO> SearchLikeOrObjects()
        {
            return SearchLikeOrObjects(0);
        }
        public List<Indico.BusinessObjects.QuoteChangeEmailListBO> SearchLikeOrObjects(int maximumRows)
        {
            return SearchLikeOrObjects(maximumRows, 0);
        }
        public List<Indico.BusinessObjects.QuoteChangeEmailListBO> SearchLikeOrObjects(int maximumRows, int startIndex)
        {
            return SearchLikeOrObjects(maximumRows, startIndex, null, false);
        }
        public List<Indico.BusinessObjects.QuoteChangeEmailListBO> SearchLikeOrObjects(int maximumRows, int startIndex, string sortExpression, bool sortDescending)
        {
            IndicoEntities context = (this.Context != null) ? this.Context.Context : new IndicoEntities();
            IQueryable<Indico.DAL.QuoteChangeEmailList> oQuery =
                (from o in context.QuoteChangeEmailList
                 where
                    (this.ID == 0 || this.ID == o.ID) && 
                    (this.User == null || this.User == o.User.ID) && 
                    (this.IsCC == false || this.IsCC == o.IsCC) 

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

            List<Indico.BusinessObjects.QuoteChangeEmailListBO> quotechangeemaillists = IQueryableToList(oQuery);
            if (this.Context == null)
            {
                context.Dispose();
            }
            
            return quotechangeemaillists;
        }
        
        public int SearchLikeOrObjectsCount()
        {
            IndicoEntities context = (this.Context != null) ? this.Context.Context : new IndicoEntities();
            return (from o in context.QuoteChangeEmailList
                 where
                    (this.ID == 0 || this.ID == o.ID) && 
                    (this.User == null || this.User == o.User.ID) && 
                    (this.IsCC == false || this.IsCC == o.IsCC) 

                 orderby o.ID
                 select o).Count();
            
        }
        #endregion
        
        #region Serialization methods
        /// <summary>
        /// Serializes the Indico.BusinessObjects.QuoteChangeEmailListBO to an XML representation
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
        /// Deserializes Indico.BusinessObjects.QuoteChangeEmailListBO object from an XML representation
        /// </summary>
        /// <param name="strXML">a XML string serialized representation</param>
        public Indico.BusinessObjects.QuoteChangeEmailListBO DeserializeObject(string strXML)
        {
            Indico.BusinessObjects.QuoteChangeEmailListBO objTemp = null;
            System.Xml.XmlDocument objXML = new System.Xml.XmlDocument();

            objXML.LoadXml(strXML);
            System.Text.Encoding encoding = System.Text.Encoding.UTF8;

            System.IO.MemoryStream objStream = new System.IO.MemoryStream();
            byte[] b = encoding.GetBytes(objXML.OuterXml);

            objStream.Write(b, 0, (int)b.Length);
            objStream.Position = 0;
            System.Xml.Serialization.XmlSerializer x = new System.Xml.Serialization.XmlSerializer(this.GetType());

            objTemp = (Indico.BusinessObjects.QuoteChangeEmailListBO)x.Deserialize(objStream);
            objStream.Close();
            return objTemp;
        }

        /// <summary>
        /// Returns a simple XML representation of Indico.BusinessObjects.QuoteChangeEmailListBO object in an XmlElement
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
            OnQuoteChangeEmailListBOIDChanged();
        }
        
        partial void OnIDChanging(int value)
        {
            if (value < 0)
            {
                throw new Exception(String.Format("QuoteChangeEmailListBO.ID must be more than or equal to 0. The supplied value was {0}.", value));
            }
            OnQuoteChangeEmailListBOIDChanging(value);
        }
        partial void OnIDChanged();
        partial void OnIDChanging(int value);
        partial void OnQuoteChangeEmailListBOIDChanged();
        partial void OnQuoteChangeEmailListBOIDChanging(int value);
        
        partial void OnUserChanged()
        {
            OnQuoteChangeEmailListBOUserChanged();
        }
        
        partial void OnUserChanging(int? value)
        {
            if (value != null && value < 0)
            {
                throw new Exception(String.Format("QuoteChangeEmailListBO.User must be null or more than or equal to 0. The supplied value was {0}.", value));
            }
            OnQuoteChangeEmailListBOUserChanging(value);
        }
        partial void OnUserChanged();
        partial void OnUserChanging(int? value);
        partial void OnQuoteChangeEmailListBOUserChanged();
        partial void OnQuoteChangeEmailListBOUserChanging(int? value);
        
        partial void OnIsCCChanged()
        {
            OnQuoteChangeEmailListBOIsCCChanged();
        }
        
        partial void OnIsCCChanging(bool value)
        {
            OnQuoteChangeEmailListBOIsCCChanging(value);
        }
        partial void OnIsCCChanged();
        partial void OnIsCCChanging(bool value);
        partial void OnQuoteChangeEmailListBOIsCCChanged();
        partial void OnQuoteChangeEmailListBOIsCCChanging(bool value);
        
        #endregion
        
        #region IComparable Members

        public int CompareTo(object obj)
        {
            if (!(obj is Indico.BusinessObjects.QuoteChangeEmailListBO))
                return 1;
            Indico.BusinessObjects.QuoteChangeEmailListBOComparer c = new Indico.BusinessObjects.QuoteChangeEmailListBOComparer();
            return c.Compare(this, obj as Indico.BusinessObjects.QuoteChangeEmailListBO);
        }

        #endregion
        #endregion
        
        #region Events
        
        void obj_PropertyChanged(object sender, System.ComponentModel.PropertyChangedEventArgs e)
        {
            if (e.PropertyName == "ID")
            {
                // reload me
                this.SetBO((Indico.DAL.QuoteChangeEmailList)sender);
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
    
    #region QuoteChangeEmailListBOComparer
    public class QuoteChangeEmailListBOComparer : IComparer<Indico.BusinessObjects.QuoteChangeEmailListBO>
    {
        private string propertyToCompareName;
        public QuoteChangeEmailListBOComparer(string propertyToCompare)
        {
            PropertyInfo p = typeof(Indico.BusinessObjects.QuoteChangeEmailListBO).GetProperty(propertyToCompare);
            if (p == null)
                throw new ArgumentException("is not a public property of Indico.BusinessObjects.QuoteChangeEmailListBO", "propertyToCompare");
            this.propertyToCompareName = propertyToCompare;
        }
        
        public QuoteChangeEmailListBOComparer()
        {
        
        }

        #region IComparer<Indico.BusinessObjects.QuoteChangeEmailListBO> Members
        public int Compare(Indico.BusinessObjects.QuoteChangeEmailListBO x, Indico.BusinessObjects.QuoteChangeEmailListBO y)
        {
            if (propertyToCompareName != null)
            {
                PropertyInfo p = typeof(Indico.BusinessObjects.QuoteChangeEmailListBO).GetProperty(propertyToCompareName);
                return compare(p, x, y);
            }
            else
            {
                PropertyInfo[] arrP = typeof(Indico.BusinessObjects.QuoteChangeEmailListBO).GetProperties();
                foreach (PropertyInfo p in arrP)
                {
                    int v = compare(p, x, y);
                    if (v != 0)
                        return v;
                }
                return 0;
            }
        }

        private int compare(PropertyInfo p, Indico.BusinessObjects.QuoteChangeEmailListBO x, Indico.BusinessObjects.QuoteChangeEmailListBO y)
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
