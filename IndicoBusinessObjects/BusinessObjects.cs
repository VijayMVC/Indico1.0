using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Linq.Expressions;
using System.Reflection;
using System.Resources;

using Indico.DAL;

namespace Indico.BusinessObjects
{
    public abstract class BusinessObject
    {
        #region Constants

        #endregion

        #region static fields

        private static ResourceManager resmgr;

        #endregion

        #region Fields

        public IndicoContext _context;
        public bool _createDAL = true;

        #endregion

        #region Static Properties

        public static bool LogErrors
        {
            get
            {
                return false;// IndicoConfiguration.AppConfiguration.IsErrorLogging;  
            }
        }

        public static string INewsDataPath
        {
            get
            {
                return null;
            }
            set
            {

            }
        }

        public static ResourceManager ResourceManager
        {
            get
            {
                if (resmgr == null)
                {
                    resmgr = new ResourceManager("Indico.IndicoStrings", Assembly.GetExecutingAssembly());
                }
                return resmgr;
            }
        }

        #endregion

        #region Properties

        public IndicoContext Context
        {
            get { return _context; }
            set { _context = value; }
        }

        #endregion

        #region Linq extension methods

        /// <summary>
        /// Provides an Expression that allows Linq to Entity queries to use "Contains" for a list of values
        /// </summary>
        /// <typeparam name="TElement">The Entity type which has the property the values of the list are compared</typeparam>
        /// <typeparam name="TValue">the type of the value to be compared</typeparam>
        /// <param name="valueSelector">The expression that selects the property value to compare to the list's values</param>
        /// <param name="values">the list of values to compare to the property value</param>
        /// <returns>Expression</returns>
        protected static Expression<Func<TElement, bool>> BuildContainsExpression<TElement, TValue>(Expression<Func<TElement, TValue>> valueSelector, IEnumerable<TValue> values)
        {

            if (null == valueSelector) { throw new ArgumentNullException("valueSelector"); }
            if (null == values) { throw new ArgumentNullException("values"); }

            ParameterExpression p = valueSelector.Parameters.Single();
            // p => valueSelector(p) == values[0] || valueSelector(p) == ...

            if (!values.Any())
            {
                return e => false;
            }

            var equals = values.Select(value => (Expression)Expression.Equal(valueSelector.Body, Expression.Constant(value, typeof(TValue))));
            var body = equals.Aggregate<Expression>((accumulate, equal) => Expression.Or(accumulate, equal));
            return Expression.Lambda<Func<TElement, bool>>(body, p);

        }

        #endregion

        #region Constructors

        public BusinessObject()
        {
        }

        public BusinessObject(IndicoContext context)
        {
            this._context = context;
        }

        public BusinessObject(IndicoContext context, bool createDAL)
        {
            this._context = context;
            this._createDAL = createDAL;
        }

        #endregion

        #region Caching methods

        protected void Cache()
        {
            PropertyInfo p = this.GetType().GetProperty("ID");
            if (p == null)
                throw new InvalidOperationException("Can't use this version of Cache() with no public ID property");
            int val = Convert.ToInt32(p.GetValue(this, null));
            if (val <= 0)
                throw new InvalidOperationException("Can't cache Business objects that have not been persisted to the store");
            string key = this.GetType().ToString() + Convert.ToString(val);

            CachedData.Add(key, this);
        }

        protected void Cache(object key)
        {
            string val = this.GetType().ToString() + Convert.ToString(key);
            CachedData.Add(val, this);
        }

        protected BusinessObject GetFromCache(object key)
        {
            string val = this.GetType().ToString() + Convert.ToString(key);
            return (BusinessObject)CachedData.GetData(val);
        }

        protected object GetFromCache(string key)
        {
            return CachedData.GetData(key);
        }

        protected void Decache()
        {
            PropertyInfo p = this.GetType().GetProperty("ID");
            if (p == null)
                throw new InvalidOperationException("Can't use this version of Cache() with no public ID property");
            int val = Convert.ToInt32(p.GetValue(this, null));
            if (val <= 0)
                throw new InvalidOperationException("Can't decache Business objects that have not been persisted to the store");
            string key = this.GetType().ToString() + Convert.ToString(val);

            CachedData.Remove(key);
        }

        #endregion

        internal static void SynchroniseEntityList<T>(
            List<T> upToDateList,
            System.Data.Objects.DataClasses.EntityCollection<T> oldList) where T : System.Data.Objects.DataClasses.EntityObject
        {
            try
            {
                if (!oldList.IsLoaded)
                    oldList.Load();

                List<T> toRemove = new List<T>();
                foreach (T obj in oldList)
                {
                    if (!upToDateList.Contains(obj))
                        toRemove.Add(obj);
                }

                foreach (T obj in toRemove)
                {
                    oldList.Remove(obj);
                }

                foreach (T obj in upToDateList)
                {
                    if (!oldList.Contains(obj))
                        oldList.Add(obj);
                }
            }
            catch { }
        }

        #region Event Handlers

        #endregion

        #region Protected Instance Methods

        /// <summary>
        /// Add object to the Cache
        /// </summary>
        /// <param name="key">Key of thee object</param>
        /// <param name="Id">Object Id if available then key will be key plus Id</param>
        /// <param name="data">value</param>
        protected void AddToCache(string key, int Id, object data)
        {
            if (Id > 0)
            {
                CachedData.Add(key + "-" + Id, data);
            }
            else
            {
                CachedData.Add(key, data);
            }
        }

        /// <summary>
        /// Delete object from Cache
        /// </summary>
        /// <param name="key">Key of the object</param>
        /// <param name="Id">Object Id if available then key will be key plus Id</param>
        protected void DeleteFromCache(string key, int Id)
        {
            if (Id > 0)
            {
                CachedData.Remove(key + "-" + Id);
            }
            else
            {
                CachedData.Remove(key);
            }
        }

        #endregion

        #region Static Methods

        public static IndicoContext CreateContext()
        {
            return new IndicoContext();
        }

        #endregion
    }

    public class IndicoDataEventArgs : EventArgs
    {
        public BusinessObject BusinessObject;

        public IndicoDataEventArgs(BusinessObject obj)
        {
            this.BusinessObject = obj;
        }
    }

    public delegate void IndicoDataEventHandler(object sender, IndicoDataEventArgs e);
}
