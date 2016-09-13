using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Indico.Common;

namespace Indico
{
    public partial class ViewDocuments : System.Web.UI.Page
    {
        #region Fields

        private string documentPath = string.Empty;

        #endregion

        #region Properties

        private string DocumentPath
        {
            get
            {
                if (documentPath == string.Empty)
                {
                    if (Session["PdfPath"] != null)
                    {
                        documentPath = Session["PdfPath"].ToString();
                    }                    
                }

                return documentPath;
            }
        }

        #endregion

        #region Events

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!this.IsPostBack)
            {
                if (!String.IsNullOrEmpty(DocumentPath))
                {
                    string filePath = Server.MapPath(DocumentPath);
                    this.Response.ContentType = "application/pdf";
                    this.Response.AppendHeader("Content-Disposition;", "attachment;filename=" + DocumentPath);
                    this.Response.WriteFile(filePath);
                    this.Response.End();
                }
            }
        }

        #endregion
    }
}