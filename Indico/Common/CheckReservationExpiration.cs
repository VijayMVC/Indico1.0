using System;
using System.Collections;
using System.Configuration;
using System.Data;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Threading;
using System.Web;
using System.Web.Hosting;
using System.Transactions;

using Indico.BusinessObjects;
using IL = Indico.BusinessObjects.IndicoLogging;
using System.Collections.Generic;
using System.Drawing;
using Dapper;
using Indico.Models;
namespace Indico.Common
{
    public class CheckReservationExpiration : IndicoPage
    {
        #region Enum

        public enum CheckReservationExpirationState
        {
            Stopped,
            Started,
            Error
        }

        #endregion

        #region Fields

        // Field declaration and intialization
        private static ReaderWriterLock rwl = new ReaderWriterLock();
        private static Thread MaintenanceWorkThread;
        public static CheckReservationExpirationState State = CheckReservationExpirationState.Stopped;

        #endregion

        #region Properties


        #endregion

        #region Constructors

        /// <summary>
        /// Default constructor
        /// </summary>
        public CheckReservationExpiration()
        {

        }

        #endregion

        #region Methods

        public static void Start()
        {
            rwl.AcquireWriterLock(Timeout.Infinite);
            try
            {
                if (MaintenanceWorkThread == null || !MaintenanceWorkThread.IsAlive)
                {
                    IL.log.Info("CheckReservationExpiration.Start() - Starting...");
                    MaintenanceWorkThread = IndicoConfiguration.GetContextAwareThread(new ThreadStart((new CheckReservationExpiration()).DoCheckReservationExpiration));
                    MaintenanceWorkThread.SetApartmentState(ApartmentState.STA);
                    MaintenanceWorkThread.Start();
                    State = CheckReservationExpirationState.Started;
                    IL.log.Info("CheckReservationExpiration.Start() - Started.");
                }
            }
            catch (Exception ex)
            {
                IL.log.ErrorFormat("CheckReservationExpiration.Start() - Error occurred, Message: {0}\nStacktrace: {1}", ex.Message, ex.StackTrace);

                State = CheckReservationExpirationState.Error;
            }
            finally
            {
                rwl.ReleaseWriterLock();
            }
        }

        /// <summary>
        /// This method will do the deletion work and sleep until the next interval starts.
        /// </summary>
        public void DoCheckReservationExpiration()
        {
            try
            {
                while (true)
                {
                    try
                    {
                        IL.log.Debug("DoCheckReservationExpirationStatus() - cycle begins...");

                        // Start checking the statuses of In Progress Quotes
                        /* QuoteBO objQuote = new QuoteBO();
                         objQuote.Status = 1;
                         List<QuoteBO> lstQuotes = objQuote.SearchObjects();
                         foreach (QuoteBO Quote in lstQuotes)
                         {
                             /// Start processing the Quote...
                             /// 

                             if (Quote.QuoteExpiryDate.ToShortDateString() == DateTime.Now.ToShortDateString())
                             {
                                 this.ChangeOrderStatus(Quote.ID);
                             }
                             if (Quote.QuoteExpiryDate.ToShortDateString() == DateTime.Now.AddDays(2).ToShortDateString())
                             {
                             }
                         }*/

                        var connection = GetIndicoConnnection();
                        string st1 = "New";
                        string st2 = "Partialy Redeemed";
                        var result = connection.Query<ReservationBalanceModel>(string.Format("SELECT * FROM [dbo].[NewFinalReservationBalanceView] WHERE Status='{0}' OR Status='{1}'",st1,st2)).ToList();
                        int count = result.Count;
                        int i = 0;

                        //getting an array for storing reservation IDs
                        int[] reservationarray = new int[count];

                        //getting an array for storing shipment dates
                        DateTime[] shippingdatearray = new DateTime[count];

                        

                        foreach(var result2 in result)
                        {
                            reservationarray[i] = result2.ID;
                            shippingdatearray[i] = result2.ShipmentDate;
                            i = i + 1;
                        }

                        DateTime todaydate = DateTime.Today.Date;
                        for(int x=0;x<count;++x)
                        {
                            if(shippingdatearray[x]<todaydate)
                            {
                                connection = GetIndicoConnnection();
                                var query = string.Format("UPDATE [dbo].[Reservation] SET Status=4 WHERE ID={0}",reservationarray[x]); 
                                connection.Execute(query);


                            }
                        }

                        IL.log.Debug("DoCheckReservationExpirationStatus() - cycle ends.");
                    }
                    catch (Exception ex)
                    {
                        IL.log.ErrorFormat("DoCheckReservationExpirationStatus() - Error occurred, Message: {0}\nStacktrace: {1}", ex.Message, ex.StackTrace);
                    }

                    // Sleep until the next inetrval starts.
                    Thread.Sleep(24 * 60 * 60 * 1000);
                    //Thread.Sleep(1000 * 60 * 1); // 1min
                }
            }
            catch (System.Threading.ThreadAbortException)
            {
                IL.log.InfoFormat("DoCheckReservationExpirationStatus Task: Caught Thread Abort.");
            }
        }

        #endregion
    }
}