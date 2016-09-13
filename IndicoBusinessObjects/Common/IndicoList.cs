using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Indico.BusinessObjects
{
    public class IndicoList<T> : List<T>
    {
        #region Constructors

        public IndicoList () {}

        public IndicoList(int capacity) : base(capacity) {}

        public IndicoList(IEnumerable<T> collection) : base(collection) { }

        #endregion

        #region Events

        // An events that clients can use to be notified whenever the
        // elements of the list changes.
        public event EventHandler OnBeforeAdd;
        public event EventHandler OnAfterAdd;
        public event EventHandler OnBeforeInsert;
        public event EventHandler OnAfterInsert;
        public event EventHandler OnBeforeRemove;
        public event EventHandler OnAfterRemove;
        public event EventHandler OnBeforeClear;
        public event EventHandler OnAfterClear;

        #endregion

        #region Event methods

        // Invoke the events
        protected void BeforeAdd(EventArgs e)
        {
            if (OnBeforeAdd != null)
            {
                OnBeforeAdd(this, e);
            }
        }

        protected void AfterAdd(EventArgs e)
        {
            if (OnAfterAdd != null)
            {
                OnAfterAdd(this, e);
            }
        }

        protected void BeforeInsert(EventArgs e)
        {
            if (OnBeforeInsert != null)
            {
                OnBeforeInsert(this, e);
            }
        }

        protected void AfterInsert(EventArgs e)
        {
            if (OnAfterInsert != null)
            {
                OnAfterInsert(this, e);
            }
        }

        protected void BeforeRemove(EventArgs e)
        {
            if (OnBeforeRemove != null)
            {
                OnBeforeRemove(this, e);
            }
        }

        protected void AfterRemove(EventArgs e)
        {
            if (OnAfterRemove != null)
            {
                OnAfterRemove(this, e);
            }
        }

        protected void BeforeClear(EventArgs e)
        {
            if (OnBeforeClear != null)
            {
                OnBeforeClear(this, e);
            }
        }

        protected void AfterClear(EventArgs e)
        {
            if (OnAfterClear != null)
            {
                OnAfterClear(this, e);
            }
        }

        #endregion

        #region Methods

        public new bool Contains(T item)
        {
            return base.Contains(item);
        }

        public new int IndexOf(T item)
        {
            return base.IndexOf(item);
        }

        public new void Insert(int index, T item)
        {
            this.BeforeInsert(EventArgs.Empty);
            base.Insert(index, item);
            this.AfterInsert(EventArgs.Empty);
        }

        public new void Add(T value)
        {
            this.BeforeAdd(EventArgs.Empty);
            base.Add(value);
            this.AfterAdd(EventArgs.Empty);
        }

        public new void Remove(T item)
        {
            this.BeforeRemove(EventArgs.Empty);
            base.Remove(item);
            this.AfterRemove(EventArgs.Empty);
        }

        public new void RemoveAt(int index)
        {
            base.RemoveAt(index);
        }

        public new void Clear()
        {
            this.BeforeClear(EventArgs.Empty);
            base.Clear();
            this.AfterClear(EventArgs.Empty);
        }

        #endregion
    }
}
