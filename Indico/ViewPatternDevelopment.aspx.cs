using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Net;
using System.Text;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using Dapper;
using Indico.Models;
using Telerik.Web.UI;
using Indico.Common;

namespace Indico
{
    public partial class ViewPatternDevelopment : IndicoPage
    {
        //public string Pattern { get; set; }
        // public bool Create { get; set; }
        public string DevelopmentId { get; set; }

        public List<GetNonDevelopedPatternsModel> NonDevelopedPatterns;

        private void GetFromQuery()
        {
            //if (Request.QueryString["Pattern"] != null)
            //{
            //    Pattern = Request.QueryString["Pattern"];
            //}
            //if (Request.QueryString["Create"] != null)
            //{
            //    Create=Request.QueryString["Create"].ToLower() == "true";
            //}
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            //if (Page.IsPostBack)
            //{
            //   return;
            //}
            // GetFromQuery();
            PopulateGrid();
            HeadLiteral.Text = "Pattern Development";
            //PopulateNonDeveloped();
        }

        protected void OnGridPageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            Grid.Rebind();
        }

        protected void OnGridPageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            Grid.Rebind();
        }

        protected void OnGridItemDataBound(object sender, GridItemEventArgs e)
        {

            if (!(e.Item is GridDataItem))
                return;
            var item = (GridDataItem)e.Item;
            if ((item.ItemIndex <= -1 || !(item.DataItem is GetPatternDevelopmentsModel)))
                return;

            var model = (GetPatternDevelopmentsModel)item.DataItem;
            var index = ((List<GetPatternDevelopmentsModel>)Session["_items"]).IndexOf(model);
            var spec = (CheckBox)item.FindControl("specCheckBox");
            spec.Attributes.Add("qid", index.ToString());
            var lectraPattern = (CheckBox)item.FindControl("lectraPatternCheckBox");
            var whiteSample = (CheckBox)item.FindControl("whiteSampleCheckBox");
            var logoPositioning = (CheckBox)item.FindControl("logoPositioningCheckBox");
            var photo = (CheckBox)item.FindControl("photoCheckBox");
            var fake3D = (CheckBox)item.FindControl("fake3dVisCheckBox");
            var nestedWireframe = (CheckBox)item.FindControl("nestedWireframeCheckBox");
            var bySizeWireframe = (CheckBox)item.FindControl("bySizeWireframeCheckBox");
            var preProd = (CheckBox)item.FindControl("preProdCheckBox");
            var specChart = (CheckBox)item.FindControl("specChartCheckBox");
            var finalTemplate = (CheckBox)item.FindControl("finalTemplateCheckBox");
            var templateApproved = (CheckBox)item.FindControl("templateApprovedCheckBox");
            var remarks = (TextBox)item.FindControl("remarksTextBox");
            item.Attributes.Add("data-id", model.ID.ToString());

            spec.Checked = model.Spec;
            item.Style.Add(HtmlTextWriterStyle.TextAlign, "center");
            item.Style.Add(HtmlTextWriterStyle.VerticalAlign, "middle");
            item["PatternNumber"].Style.Add(HtmlTextWriterStyle.TextAlign, "left");
            item["PatternNumber"].Style.Add(HtmlTextWriterStyle.VerticalAlign, "left");
            item["Description"].Style.Add(HtmlTextWriterStyle.TextAlign, "left");
            item["Description"].Style.Add(HtmlTextWriterStyle.VerticalAlign, "left");
            lectraPattern.Checked = model.LectraPattern;
            whiteSample.Checked = model.WhiteSample;
            logoPositioning.Checked = model.LogoPositioning;
            photo.Checked = model.Photo;
            fake3D.Checked = model.Fake3DVis;
            nestedWireframe.Checked = model.NestedWireframe;
            bySizeWireframe.Checked = model.BySizeWireframe;
            preProd.Checked = model.PreProd;
            specChart.Checked = model.SpecChart;
            finalTemplate.Checked = model.FinalTemplate;
            templateApproved.Checked = model.TemplateApproved;
            remarks.Text = model.Remarks;
            var checkBoxes = new List<CheckBox>() { spec, lectraPattern, whiteSample, logoPositioning, photo, fake3D, nestedWireframe, bySizeWireframe, preProd, specChart, finalTemplate, templateApproved };
            foreach (var cb in checkBoxes)
            {
                cb.Enabled = false;
                cb.Attributes.Add("data-field", cb.ID.Replace("CheckBox", ""));
            }
            for (var i = 0; i < checkBoxes.Count; i++)
            {
                if (i == 0)
                {
                    if (!checkBoxes[i].Checked)
                    {
                        checkBoxes[i].Enabled = true;
                        break;
                    }
                }
                var checkBox = checkBoxes[i];
                if (checkBox.Checked)
                {
                    if (i >= checkBoxes.Count - 1)
                        checkBox.Enabled = false;
                    else
                    {
                        checkBox.Enabled = false;
                        checkBoxes[i + 1].Enabled = true;
                    }
                }
                else
                {
                    checkBox.Enabled = true;
                    break;
                }
            }
        }

        private void PopulateGrid()
        {
            using (var connection = new SqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString))
            {
                var list = connection.Query<GetPatternDevelopmentsModel>(string.Format("EXEC [dbo].[SPC_GetPatternDevelopments]")).ToList();
                Session["_items"] = list;
                Grid.DataSource = list;
                Grid.DataBind();

            }
        }

        [WebMethod]
        public static string SaveChanges(string developmentId, string field, string value, string loggedUser)
        {
            var column = "";
            var name = "";
            switch (field)
            {
                case "spec":
                    column = "[Spec]";
                    name = "Spec";
                    break;
                case "lectraPattern":
                    column = "[LectraPattern]";
                    name = "Lectra Pattern";
                    break;
                case "whiteSample":
                    column = "[WhiteSample]";
                    name = "White Sample";
                    break;
                case "logoPositioning":
                    column = "[LogoPositioning]";
                    name = "Logo Positioning";
                    break;
                case "photo":
                    column = "[Photo]";
                    name = "Photo";
                    break;
                case "fake3dVis":
                    column = "[Fake3DVis]";
                    name = "Fake 3D Vis";
                    break;
                case "nestedWireframe":
                    column = "[NestedWireframe]";
                    name = "Nested Wireframe";
                    break;
                case "bySizeWireframe":
                    column = "[BySizeWireframe]";
                    name = "By Size Wireframe";
                    break;
                case "preProd":
                    column = "[PreProd]";
                    name = "Pre Prod";
                    break;
                case "specChart":
                    column = "[SpecChart]";
                    name = "Spec Chart";
                    break;
                case "finalTemplate":
                    column = "[FinalTemplate]";
                    name = "Final Template";
                    break;
                case "templateApproved":
                    column = "[TemplateApproved]";
                    name = "Template Approved";
                    break;
            }
            if (column == "")
                throw new WebException("Column Name Incorrect");
            var query = string.Format("UPDATE [dbo].[PatternDevelopment] SET {0} = {1}, LastModified = '{2}', LastModifier = {3} WHERE ID = {4} ", column, value, DateTime.Now, loggedUser, developmentId);

            using (var connection = new SqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString))
            {
                connection.Execute(query);
                query = string.Format("INSERT INTO [dbo].[PatternDevelopmentHistory] ([PatternDevelopment],[Modifier],[ModifiedDate],[ChangeDescription]) VALUES({0},{1},'{2}','{3}')", developmentId, loggedUser, DateTime.Now, string.Format("{0} Completed", name));
                connection.Execute(query);
                return "Done";
            }
        }

        [WebMethod]
        public static void SaveRemarks(string remarks, string id)
        {
            int identity;
            if (!int.TryParse(id, out identity))
                throw new WebException("id is wrong");
            using (var connection = new SqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString))
            {
                connection.Execute(string.Format("UPDATE [dbo].[PatternDevelopment] SET Remarks = '{0}' WHERE ID = {1}", remarks, id));
            }
        }

        [WebMethod]
        public static string GetHistory(string id)
        {
            int identity;
            if (!int.TryParse(id, out identity))
                throw new WebException("id is wrong");
            using (var connection = new SqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString))
            {
                var items = connection.Query<GetPatternDevelopmentHistoryModel>("EXEC [dbo].[SPC_GetPatterDevelopmentHistory] " + identity).ToList();
                if (items.Count <= 0)
                    return "<h4>No History Found For The Selected Pattern Development</h4>";
                var html = new StringBuilder();
                html.Append("<h4>Pattern Development History </h4>");
                const string thead = "<thead>" +
                                     "<tr>" +
                                     "<th>User</th>" +
                                     "<th>Time</th>" +
                                     "<th>Description</th>" +
                                     "</tr>" +
                                     "</thead>";
                var tbodyrows = items.Aggregate("", (current, itme) => current + (Environment.NewLine + string.Format(
                    "<tr>" +
                    "<td>{0}</td>" +
                    "<td>{1}</td>" +
                    "<td>{2}</td>" +
                    "</tr>", itme.UserName, itme.ModifiedDate.GetValueOrDefault(), itme.ChangeDescription)));
                html.Append(string.Format("<table class=\"table table-hover\">{0}<tbody>{1}</tbody></table>", thead, tbodyrows));
                return html.ToString();
            }
        }
    }
}