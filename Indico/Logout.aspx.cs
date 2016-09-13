using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.SessionState;
using System.Web.UI;
using System.Web.UI.WebControls;

using Indico.BusinessObjects;
using Indico.Common;

namespace Indico
{
    public partial class Logout : IndicoPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Response.Cookies["indico-usrnm"].Value = string.Empty;
            Response.Cookies["indico-usrnm"].Expires = DateTime.Now.AddDays(-15);
            Response.Cookies["indico-pswrd"].Value = string.Empty;
            Response.Cookies["indico-pswrd"].Expires = DateTime.Now.AddDays(-15);

            try
            {
                if (HttpContext.Current.Session["in_sid"] != null)
                {
                    UserBO objUser = this.LoggedUser;
                    Session["UserMenuItemRoleView" + this.LoggedUser.ID] = null;

                    IndicoPage.EndSession(ref objUser);
                }
                Session.Abandon();
            }
            catch { }

            SessionIDManager manager = new SessionIDManager();
            var isRedirected = false; var isAdded = false;
            manager.SaveSessionID(this.Context, manager.CreateSessionID(Context), out isRedirected, out isAdded);

            Response.Redirect("/Login.aspx");
        }
    }
}
