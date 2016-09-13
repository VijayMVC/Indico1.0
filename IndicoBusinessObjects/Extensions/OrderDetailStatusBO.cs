using System;
using System.Collections.Generic;
using System.Linq;
using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class OrderDetailStatusBO : BusinessObject
    {
        #region Enums

        public enum ODStatus
        {
            New = 0,
            ODSPrinted = 1,
            PrintingStarted = 2,
            HeatPressStarted = 3,
            SewingStarted = 4,
            PackingStarted = 5,
            ShippingStarted = 6,
            Completed = 7,
            PrintCompleted = 8,
            HeatPressCompleted = 9,
            SewingCompleted = 10,
            PackingCompleted = 11,
            ShippingCompleted = 12,
            Submitted = 13,
            OnHold = 14,
            Cancelled = 15,
            Shipped = 16,
            PreShipped = 17,
            WaitingInfo = 18
        }

        #endregion

        #region OnPropertyChange Methods
        // Put implementations of OnBusinessObjectNameBOPropertyNameChanging()
        // and OnBusinessObjectNameBOPropertyNameChanged() here

        #endregion

        #region Extension Methods
        // Put methods to manipulate Business Objects here. Add, Update etc
        #endregion
    }
}

