using System;
using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class SupplierBO : BusinessObject
    {
        #region Public Constructors
        /// <summary>
        /// Creates an instance of the SupplierBO class. 
        /// </summary>
        public SupplierBO(){}
		
		/// <summary>
        /// Creates an instance of the SupplierBO class passing the IndicoContext object reference.
        /// </summary>
        public SupplierBO(ref IndicoContext context) : base(context)
		{
			if (context != null)
			{
				context.OnSendBeforeChanges += new EventHandler(Context_OnSendBeforeChanges); 
				context.OnSendAfterChanges += new EventHandler(Context_OnSendAfterChanges); 
			}
		}
		
		/// <summary>
        /// Creates an instance of the SupplierBO class passing the IndicoContext object. 
        /// </summary>
        public SupplierBO(IndicoContext context) : base(context)
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
        public SupplierBO(ref IndicoContext context, bool createDAL) : base(context, createDAL)
        {

        }

        #endregion
    }
}

