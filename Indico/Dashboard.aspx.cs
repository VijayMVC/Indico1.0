using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;

using Indico.BusinessObjects;
using Indico.Common;

namespace Indico
{
    public partial class Dashboard : IndicoPage
    {
        #region Fields

        #endregion

        #region Properties

        #endregion

        #region Constructors

        #endregion

        #region Events

        /// <summary>
        /// Page load event.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>

        protected override void OnPreRender(EventArgs e)
        {
            //Page Refresh
            Session["IsPostBack"] = Server.UrlEncode(Guid.NewGuid().ToString());
            ViewState["IsPostBack"] = Session["IsPostBack"];
        }
        
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!this.IsPostBack)
            {
                PopulateControls();
            }
        }

        #endregion

        #region Methods

        /// <summary>
        /// Populate the controls.
        /// </summary>
        private void PopulateControls()
        {
            this.litHeaderText.Text = this.ActivePage.Heading;
            this.litCompanyName.Text = LoggedCompany.Name;
            //if (LoggedUserRoleName == UserRole.DistributorAdministrator || LoggedUserRoleName == UserRole.DistributorCoordinator)
            //{
            //    List<OrderBO> lstClientOrderHeader = (new OrderBO()).GetAllObject().Where(o => (o.Status == 18 || o.Status == 22) && o.objCreator.Company == LoggedCompany.ID).ToList();
            //    if (lstClientOrderHeader.Count > 0)
            //    {
            //        //this.dvClientOrderDetails.Visible = true;
            //        this.litOrderCount.Text = lstClientOrderHeader.Count.ToString() + " ";                    
            //    }
            //    this.ancOrderCount.HRef = "/ViewOrders.aspx";
            //}
            this.ancOrderCount.HRef = "/ViewOrders.aspx";
        }

        #endregion
    }
}
