using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Indico.Common
{
    public class TemplateHandler:ITemplate
    {
        public string txtID { get; set; }
        public string Text { get; set; }        

        public void InstantiateIn(Control container)
        {
            TextBox txt = new TextBox();

            txt.Width = 50;            
            txt.Text = Text;
            container.Controls.Add(txt);
        }
    }
}