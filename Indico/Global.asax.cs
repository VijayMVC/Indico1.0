using System;
using System.Web;

using Indico.BusinessObjects;
using Indico.Common;

namespace Indico
{
    public class Global : System.Web.HttpApplication
    {
        protected void Application_Start(object sender, EventArgs e)
        {
            

            // Check for expired Quotes            
            if (CheckQuotes.State != CheckQuotes.CheckQuoteState.Started)
                CheckQuotes.Start();

            if (CheckReservationExpiration.State != CheckReservationExpiration.CheckReservationExpirationState.Started)
                CheckReservationExpiration.Start();
        }

        protected void Application_End(object sender, EventArgs e)
        {

        }

        protected void Application_Error(object sender, EventArgs e)
        {
            Exception exception = Server.GetLastError();
             while (exception != null && exception.InnerException != null)
            {
                exception = exception.InnerException;
            }

            IndicoLogging.log.Error("Application_Error() Unhandled exception encountered. Message was \"{0}\" .", exception);
            Response.Clear();

            HttpException httpException = exception as HttpException;
            if (httpException != null)
            {
                string redirectAction;
                switch (httpException.GetHttpCode())
                {
                    case 404: // page not found
                        {
                            redirectAction = "Cannotcontinued.html";
                            break;
                        }
                    case 500: // server error
                        {
                            redirectAction = "UnexpectedError.html";
                            break;
                        }
                    default:
                        {
                            redirectAction = "Unauthorised.html";
                            break;
                        }
                }
                // Clear error on server
                Server.ClearError();
                Server.Transfer(redirectAction);
            }
            //else
            //{
            Server.Transfer("Error.aspx");
            //}
        }

        protected void Session_Start(object sender, EventArgs e)
        {

        }

        protected void Session_End(object sender, EventArgs e)
        {

        }

        protected void Application_BeginRequest(object sender, EventArgs e)
        {
            HttpApplication application = (HttpApplication)sender;
            HttpContext context = application.Context;
            if (context.Request.AppRelativeCurrentExecutionFilePath.EndsWith(".aspx", StringComparison.OrdinalIgnoreCase))
            {
                Request.Filter = new IndicoHttpRequestFilter(Request.Filter);
            }
        }

        protected void Application_AuthenticateRequest(object sender, EventArgs e)
        {

        }

        public override string GetVaryByCustomString(HttpContext context, string custom)
        {
            if ((custom.ToLower() == "navigation") && !String.IsNullOrEmpty(context.Request.CurrentExecutionFilePath) && (context.Session["in_cid"] != null) && (context.Session["in_uid"] != null))
            {
                return custom + context.Request.CurrentExecutionFilePath + context.Session["in_cid"].ToString() + context.Session["in_uid"].ToString() + context.Session.SessionID;
            }
            else
            {
                return base.GetVaryByCustomString(context, custom);
            }
        }
    }
}
