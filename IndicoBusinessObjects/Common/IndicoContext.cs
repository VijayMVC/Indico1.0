using System;
using System.Collections.Generic;
using System.Configuration; 
using System.Data; 
using System.Linq;
using System.Web;

using Indico.DAL;

namespace Indico.BusinessObjects
{
    public class IndicoContext : IDisposable
    {
        #region Fields

        private IndicoEntities _context = null;
        public event EventHandler OnSendBeforeChanges;
        public event EventHandler OnSendAfterChanges;

        #endregion

        #region Constructors

        public IndicoContext()
        {
            _context = new IndicoEntities(ConfigurationManager.ConnectionStrings[1].ConnectionString);
        }

        public IndicoEntities Context
        {
            get { return _context; }
        }

        public void Refresh()
        {
           // _context.Refresh(System.Data.Objects.RefreshMode.ClientWins, this);
        }

        public void AcceptAllChanges()
        {
            _context.AcceptAllChanges();
        }

        #endregion

        #region Events

        // Invoke the events
        protected void SendBeforeChanges(EventArgs e)
        {
            if (OnSendBeforeChanges != null)
            {
                OnSendBeforeChanges(this, e);
            }
        }

        protected void SendAfterChanges(EventArgs e)
        {
            if (OnSendAfterChanges != null)
            {
                OnSendAfterChanges(this, e);
            }
        }

        #endregion

        #region Methods

        public bool SaveChanges()
        {
            return SaveChanges(true);
        }

        public bool SaveChanges(bool acceptAllChanges)
        {
            bool retVal = false;
            try
            {
                this.SendBeforeChanges(EventArgs.Empty);
                _context.SaveChanges(acceptAllChanges);
                this.SendAfterChanges(EventArgs.Empty);
                retVal = true;
            }
            catch (OptimisticConcurrencyException)
            {
                _context.Refresh(System.Data.Objects.RefreshMode.ClientWins, this);
                _context.SaveChanges(acceptAllChanges);
                this.SendAfterChanges(EventArgs.Empty);
                retVal = true;
            }
            catch (System.Data.DeletedRowInaccessibleException cEx)
            {                
                // Log the error
                IndicoLogging.log.Error(String.Format("Error occured in SaveChanges({0}) method call. Exception : {1}", acceptAllChanges.ToString(), cEx.ToString()));
            }
            return retVal;
        }

        public void Dispose()
        {
            if (_context != null)
            {
                _context.Dispose();
            }
        }

        #endregion
    }
}
