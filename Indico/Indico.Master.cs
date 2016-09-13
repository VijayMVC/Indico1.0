using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;

using Indico.BusinessObjects;

namespace Indico
{
    public partial class Indico : System.Web.UI.MasterPage
    {
        #region Fields

        #endregion

        #region Properties

        protected string DataFolderName
        {
            get
            {
                return IndicoConfiguration.AppConfiguration.DataFolderName;
            }
        }

        #endregion

        #region Constructors

        #endregion

        #region Events

        /// <summary>
        /// Page load event.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        #endregion

        #region Methods

        #endregion
    }
}