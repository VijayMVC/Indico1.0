using System;
using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class PageBO : BusinessObject
    {
        #region Public Constructors
        /// <summary>
        /// Creates an instance of the PageBO class. 
        /// </summary>
        public PageBO(){}
		
		/// <summary>
        /// Creates an instance of the PageBO class passing the IndicoContext object reference.
        /// </summary>
        public PageBO(ref IndicoContext context) : base(context)
		{
			if (context != null)
			{
				context.OnSendBeforeChanges += new EventHandler(Context_OnSendBeforeChanges); 
				context.OnSendAfterChanges += new EventHandler(Context_OnSendAfterChanges); 
			}
		}
		
		/// <summary>
        /// Creates an instance of the PageBO class passing the IndicoContext object. 
        /// </summary>
        public PageBO(IndicoContext context) : base(context)
		{
			if (context != null)
			{
				context.OnSendBeforeChanges += new EventHandler(Context_OnSendBeforeChanges); 
				context.OnSendAfterChanges += new EventHandler(Context_OnSendAfterChanges); 
			}
		}
		
		/// <summary>
        /// Creates an instance of the ProductBO class giving the IndicoContext object. 
		/// createDAL parameter decides whether to be created or not the DAL for this business object. 
        /// </summary>
        public PageBO(ref IndicoContext context, bool createDAL) : base(context, createDAL)
        {

        }

        #endregion
    }
}

