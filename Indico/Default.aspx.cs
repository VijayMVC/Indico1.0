using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using Indico.BusinessObjects;
using Indico.Common;

namespace Indico
{
    public partial class Default : IndicoPage
    {
        #region Fields
        
        #endregion

        #region Properties

        #endregion

        #region Events

        /// <summary>
        /// Page load event.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
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
            if (this.LoggedUser != null)
            {
                if (this.LoggedUserRole.ID > 0)
                {
                    try
                    {
                        UserBO objUBO = new UserBO(this.ObjContext);
                        objUBO.ID = this.LoggedUser.ID;
                        objUBO.GetObject();

                        Session["in_log"] = objUBO.DateLastLogin.ToString();

                        objUBO.DateLastLogin = (DateTime?)(Convert.ToDateTime(DateTime.Now.ToString("g")));
                        this.ObjContext.SaveChanges();
                    }
                    catch (Exception ex)
                    {
                        IndicoLogging.log.ErrorFormat("Error occured while updateing user last logged date. Exception : " + ex.Message.ToString());
                    }                  
                    
                    if (this.LoggedUserRole != null)
                    {   
                        switch (this.LoggedUserRoleName)
                        {
                            case UserRole.SiteAdministrator:
                                {
                                    Response.Redirect("/ViewUsers.aspx");
                                    break;
                                }
                            case UserRole.FactoryAdministrator:
                            case UserRole.FactoryCoordinator:                           
                                {
                                    Response.Redirect("/Home.aspx");
                                    break;
                                }
                            case UserRole.FactoryPatternDeveloper:
                                {
                                    Response.Redirect("/ViewPatterns.aspx");
                                    break;
                                }   
                            case UserRole.IndimanAdministrator:
                            case UserRole.IndimanCoordinator:
                                {
                                    Response.Redirect("/Home.aspx");
                                    break;
                                }
                            case UserRole.IndicoAdministrator:
                            case UserRole.IndicoCoordinator:
                                {
                                    Response.Redirect("/ViewOrders.aspx");
                                    break;
                                }                            
                            case UserRole.IndicoPatternDeveloper:
                                {
                                    Response.Redirect("/ViewPatterns.aspx");
                                    break;
                                }
                            case UserRole.DistributorAdministrator:
                            case UserRole.DistributorCoordinator:
                                {
                                    Response.Redirect("/ViewOrders.aspx");
                                    break;
                                }
                            case UserRole.NotAssigned:                              
                            default:
                                {
                                    Response.Redirect("/NotConfigured.html");
                                    break;
                                }
                        }
                    }
                }
                else
                {
                    Response.Redirect(this.UnauthorisedURL);
                }
            }
            else if (this.IsMaintenanceMode)
            {
                Response.Redirect(this.MaintenanceURL);
            }
            else
            {
                Response.Redirect("/Logout.aspx");
            }
        }

        #endregion
    }
}