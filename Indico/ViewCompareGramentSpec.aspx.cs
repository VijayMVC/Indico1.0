using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Linq.Dynamic;
using System.Transactions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Telerik.Web.UI;

using Indico.BusinessObjects;
using Indico.Common;

namespace Indico
{
    public partial class ViewCompareGramentSpec : IndicoPage
    {
        #region Field

        #endregion

        #region Properties

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["UsersSortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "Name";
                }
                return sort;
            }
            set
            {
                ViewState["UsersSortExpression"] = value;
            }
        }

        public bool IsNotRefresh
        {
            get
            {
                return (Session["IsPostBack"].ToString() == ViewState["IsPostBack"].ToString());
            }
        }

        #endregion

        #region Constructors

        #endregion

        #region Event

        protected void Page_PreRender(object sender, EventArgs e)
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

        protected void ddlPattern_SelectedIndexChanged(object sender, EventArgs e)
        {
            int id = int.Parse(this.ddlPattern.SelectedValue);

            if (id > 0)
            {
                this.ddlComparePattern.Enabled = true;

                this.Repopulate();

                PatternBO objPattern = new PatternBO();
                objPattern.ID = id;
                objPattern.GetObject();

                this.litPattern1.Text = objPattern.Number + " - " + objPattern.NickName;

                PatternBO objPat = new PatternBO();
                objPat.SizeSet = objPattern.SizeSet;
                objPat.Item = objPattern.Item;

                List<PatternBO> lstPattern = objPat.SearchObjects().Where(o => o.ID != id).ToList();

                this.ddlComparePattern.Items.Clear();
                this.ddlComparePattern.Items.Add(new ListItem("Select Next Pattern", "0"));

                if (lstPattern.Count > 0)
                {
                    foreach (PatternBO pat in lstPattern)
                    {
                        this.ddlComparePattern.Items.Add(new ListItem(pat.Number + " - " + pat.NickName, pat.ID.ToString()));
                    }

                }
                else
                {
                    this.ddlComparePattern.Enabled = false;
                }

                this.PopulateOriginalPatternSpec(objPattern.ID);
            }
        }

        protected void btnCompareGarmenSpec_ServerClick(object sender, EventArgs e)
        {
            int comid = int.Parse(this.ddlComparePattern.SelectedValue);

            if (comid > 0)
            {
                this.ComparePatternGarmentSpec(comid);

                this.GetDiffrenceGarmentSpec(int.Parse(this.ddlPattern.SelectedValue), comid);
            }
            else
            {
                this.legPattern02.Visible = false;
                this.dvComparePattern.Visible = false;

                this.legDiffrence.Visible = false;
                this.dvDiffrence.Visible = false;
            }
        }

        protected void rptSpecSizeQtyHeader_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is SizeChartBO)
            {
                SizeChartBO objSizeChart = (SizeChartBO)item.DataItem;

                Literal litCellHeader = (Literal)item.FindControl("litCellHeader");
                litCellHeader.Text = objSizeChart.objSize.SizeName;
            }
        }

        protected void rptSpecML_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is IGrouping<int, SizeChartBO>)
            {
                List<SizeChartBO> lstSizeChart = ((IGrouping<int, SizeChartBO>)item.DataItem).ToList();

                MeasurementLocationBO objML = new MeasurementLocationBO();
                objML.ID = lstSizeChart[0].MeasurementLocation;
                objML.GetObject();

                Literal litCellHeaderKey = (Literal)item.FindControl("litCellHeaderKey");
                litCellHeaderKey.Text = objML.Key;

                Literal litCellHeaderML = (Literal)item.FindControl("litCellHeaderML");
                litCellHeaderML.Text = objML.Name;

                Repeater rptSpecSizeQty = (Repeater)item.FindControl("rptSpecSizeQty");
                rptSpecSizeQty.DataSource = lstSizeChart;
                rptSpecSizeQty.DataBind();
            }
        }

        protected void rptSpecSizeQty_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is SizeChartBO)
            {
                SizeChartBO objSizeChart = (SizeChartBO)item.DataItem;

                TextBox txtQty = (TextBox)item.FindControl("txtQty");
                txtQty.Text = Math.Round(objSizeChart.Val).ToString();

                txtQty.Attributes.Add("qid", objSizeChart.ID.ToString());
                txtQty.Attributes.Add("MLID", objSizeChart.MeasurementLocation.ToString());
                txtQty.Attributes.Add("SID", objSizeChart.Size.ToString());
            }
        }

        protected void rptCompareSpecSizeQtyHeader_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is SizeChartBO)
            {
                SizeChartBO objSizeChart = (SizeChartBO)item.DataItem;

                Literal litCellHeader = (Literal)item.FindControl("litCellHeader");
                litCellHeader.Text = objSizeChart.objSize.SizeName;
            }
        }

        protected void rptCompareSpecML_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is IGrouping<int, SizeChartBO>)
            {
                List<SizeChartBO> lstSizeChart = ((IGrouping<int, SizeChartBO>)item.DataItem).ToList();

                MeasurementLocationBO objML = new MeasurementLocationBO();
                objML.ID = lstSizeChart[0].MeasurementLocation;
                objML.GetObject();

                Literal litCellHeaderKey = (Literal)item.FindControl("litCellHeaderKey");
                litCellHeaderKey.Text = objML.Key;

                Literal litCellHeaderML = (Literal)item.FindControl("litCellHeaderML");
                litCellHeaderML.Text = objML.Name;

                Repeater rptCompareSpecSizeQty = (Repeater)item.FindControl("rptCompareSpecSizeQty");
                rptCompareSpecSizeQty.DataSource = lstSizeChart;
                rptCompareSpecSizeQty.DataBind();
            }
        }

        protected void rptCompareSpecSizeQty_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is SizeChartBO)
            {
                SizeChartBO objSizeChart = (SizeChartBO)item.DataItem;

                TextBox txtQty = (TextBox)item.FindControl("txtQty");
                txtQty.Text = Math.Round(objSizeChart.Val).ToString();

                // txtQty.Attributes.Add("qid", objSizeChart.ID.ToString());
                txtQty.Attributes.Add("MLID", objSizeChart.MeasurementLocation.ToString());
                txtQty.Attributes.Add("SID", objSizeChart.Size.ToString());
            }
        }

        protected void rptDiffSpecSizeQtyHeader_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is SizeChartBO)
            {
                SizeChartBO objSizeChart = (SizeChartBO)item.DataItem;

                Literal litCellHeader = (Literal)item.FindControl("litCellHeader");
                litCellHeader.Text = objSizeChart.objSize.SizeName;
            }
        }

        protected void rptDiffSpecML_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is IGrouping<int, SizeChartBO>)
            {
                List<SizeChartBO> lstSizeChart = ((IGrouping<int, SizeChartBO>)item.DataItem).ToList();

                MeasurementLocationBO objML = new MeasurementLocationBO();
                objML.ID = lstSizeChart[0].MeasurementLocation;
                objML.GetObject();

                Literal litCellHeaderKey = (Literal)item.FindControl("litCellHeaderKey");
                litCellHeaderKey.Text = objML.Key;

                Literal litCellHeaderML = (Literal)item.FindControl("litCellHeaderML");
                litCellHeaderML.Text = objML.Name;

                Repeater rptDiffSpecSizeQty = (Repeater)item.FindControl("rptDiffSpecSizeQty");
                rptDiffSpecSizeQty.DataSource = lstSizeChart;
                rptDiffSpecSizeQty.DataBind();
            }
        }

        protected void rptDiffSpecSizeQty_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is SizeChartBO)
            {
                SizeChartBO objSizeChart = (SizeChartBO)item.DataItem;

                TextBox txtQty = (TextBox)item.FindControl("txtQty");
                txtQty.Text = Math.Round(objSizeChart.Val).ToString();

                // txtQty.Attributes.Add("qid", objSizeChart.ID.ToString());
                txtQty.Attributes.Add("MLID", objSizeChart.MeasurementLocation.ToString());
                txtQty.Attributes.Add("SID", objSizeChart.Size.ToString());

                #region Color Selection

                if (objSizeChart.Val >= 6)
                {
                    txtQty.Style.Add("background-color", "#FF0000");
                }
                else if (objSizeChart.Val <= -6)
                {
                    txtQty.Style.Add("background-color", "#FF2828");
                }
                else if (objSizeChart.Val == 5)
                {
                    txtQty.Style.Add("background-color", "#FF3030");
                }
                else if (objSizeChart.Val == -5)
                {
                    txtQty.Style.Add("background-color", "#FF3C3C");
                }
                else if (objSizeChart.Val == 4)
                {
                    txtQty.Style.Add("background-color", "#FF4848");
                }
                else if (objSizeChart.Val == -4)
                {
                    txtQty.Style.Add("background-color", "#FF5555");
                }
                else if (objSizeChart.Val == 3)
                {
                    txtQty.Style.Add("background-color", "#FF5C5C");
                }
                else if (objSizeChart.Val == -3)
                {
                    txtQty.Style.Add("background-color", "#FF6E6E");
                }
                else if (objSizeChart.Val == 2)
                {
                    txtQty.Style.Add("background-color", "#FE7979");
                }
                else if (objSizeChart.Val == -2)
                {
                    txtQty.Style.Add("background-color", "#FF7575");
                }
                else if (objSizeChart.Val == 1)
                {
                    txtQty.Style.Add("background-color", "#FCBBBB");
                }
                else if (objSizeChart.Val == -1)
                {
                    txtQty.Style.Add("background-color", "#FFD7D7");
                }
                #endregion
            }
        }

        #endregion

        #region Methods

        private void PopulateControls()
        {
            // Header Text
            this.litHeaderText.Text = this.ActivePage.Heading;

            this.ddlPattern.Items.Clear();
            this.ddlPattern.Items.Add(new ListItem("Select a Pattern", "0"));
            List<PatternBO> lstPatterns = (new PatternBO()).GetAllObject().Where(o => o.IsActive == true).ToList();

            foreach (PatternBO pat in lstPatterns)
            {
                this.ddlPattern.Items.Add(new ListItem(pat.Number + " - " + pat.NickName, pat.ID.ToString()));
            }

        }

        private void PopulateOriginalPatternSpec(int pattern)
        {
            PatternBO objPattern = new PatternBO();
            objPattern.ID = pattern;
            objPattern.GetObject();

            SizeSetBO objSizeSet = new SizeSetBO();
            objSizeSet.ID = objPattern.SizeSet;
            objSizeSet.GetObject();

            List<SizeChartBO> lstSizeCharts = objPattern.SizeChartsWhereThisIsPattern;

            List<IGrouping<int, SizeChartBO>> lstSizeChartGroup = lstSizeCharts.OrderBy(o => o.objMeasurementLocation.Key).GroupBy(o => o.MeasurementLocation).ToList();

            if (lstSizeChartGroup.Count > 0)
            {
                this.rptSpecSizeQtyHeader.DataSource = (List<SizeChartBO>)lstSizeChartGroup[0].ToList();
                this.rptSpecSizeQtyHeader.DataBind();

                this.rptSpecML.DataSource = lstSizeChartGroup;
                this.rptSpecML.DataBind();


            }

            this.ddlComparePattern.Enabled = (lstSizeCharts.Count > 0) ? true : false;
            this.dvEmptyPattern.Visible = (lstSizeCharts.Count > 0) ? false : true;
            this.linkPattern.NavigateUrl = "~/AddEditPattern.aspx?id=" + objPattern.ID.ToString();
            this.dvOriginalPattern.Visible = (lstSizeCharts.Count > 0) ? true : false;
            this.legPattern01.Visible = true;
        }

        private void ComparePatternGarmentSpec(int pattern)
        {
            PatternBO objPattern = new PatternBO();
            objPattern.ID = pattern;
            objPattern.GetObject();

            this.litPattern2.Text = objPattern.Number + " - " + objPattern.NickName;

            List<SizeChartBO> lstSizeCharts = objPattern.SizeChartsWhereThisIsPattern;


            List<IGrouping<int, SizeChartBO>> lstSizeChartGroup = lstSizeCharts.OrderBy(o => o.objMeasurementLocation.Key).GroupBy(o => o.MeasurementLocation).ToList();

            if (lstSizeChartGroup.Count > 0)
            {
                this.rptCompareSpecSizeQtyHeader.DataSource = (List<SizeChartBO>)lstSizeChartGroup[0].ToList();
                this.rptCompareSpecSizeQtyHeader.DataBind();

                this.rptCompareSpecML.DataSource = lstSizeChartGroup;
                this.rptCompareSpecML.DataBind();

            }

            this.dvComparePatternEmpty.Visible = (lstSizeCharts.Count > 0) ? false : true;
            this.linkComparePattern.NavigateUrl = "~/AddEditPattern.aspx?id=" + objPattern.ID.ToString();
            this.dvEmptyDiffrence.Visible = (lstSizeCharts.Count > 0) ? false : true;
            this.dvComparePattern.Visible = (lstSizeChartGroup.Count > 0) ? true : false;
            this.dvDiffrence.Visible = (lstSizeChartGroup.Count > 0) ? true : false;
            this.legPattern02.Visible = true;
            this.legDiffrence.Visible = true;
        }

        private void GetDiffrenceGarmentSpec(int original, int compare)
        {
            PatternBO objOriPattern = new PatternBO();
            objOriPattern.ID = original;
            objOriPattern.GetObject();

            PatternBO objComPattern = new PatternBO();
            objComPattern.ID = compare;
            objComPattern.GetObject();

            List<SizeChartBO> lstDiffrence = new List<SizeChartBO>();

            List<SizeChartBO> lstOriSizeCharts = objOriPattern.SizeChartsWhereThisIsPattern;

            List<SizeChartBO> lstCComSizeCharts = objComPattern.SizeChartsWhereThisIsPattern;

            foreach (SizeChartBO osc in lstOriSizeCharts)
            {

                foreach (SizeChartBO csc in lstCComSizeCharts)
                {
                    if (osc.Size == csc.Size && osc.MeasurementLocation == csc.MeasurementLocation)
                    {
                        decimal difference = (osc.Val - csc.Val);

                        MeasurementLocationBO objM = new MeasurementLocationBO();
                        objM.ID = csc.MeasurementLocation;
                        objM.GetObject();

                        SizeBO objSize = new SizeBO();
                        objSize.ID = csc.Size;
                        objSize.GetObject();

                        SizeChartBO objSizeChart = new SizeChartBO();
                        objSizeChart.ID = 0;
                        objSizeChart.Pattern = csc.Pattern;// Not necessary
                        objSizeChart.MeasurementLocation = osc.MeasurementLocation;
                        objSizeChart.objPattern = objComPattern;
                        objSizeChart.Size = csc.Size;
                        objSizeChart.objSize = objSize;
                        objSizeChart.MeasurementLocation = csc.MeasurementLocation;
                        objSizeChart.objMeasurementLocation = objM;
                        objSizeChart.Val = difference;

                        lstDiffrence.Add(objSizeChart);
                    }
                }
            }

            List<IGrouping<int, SizeChartBO>> lstSizeChartGroup = lstDiffrence.OrderBy(o => o.objMeasurementLocation.Key).GroupBy(o => o.MeasurementLocation).ToList();

            if (lstSizeChartGroup.Count > 0)
            {
                this.rptDiffSpecSizeQtyHeader.DataSource = (List<SizeChartBO>)lstSizeChartGroup[0].ToList();
                this.rptDiffSpecSizeQtyHeader.DataBind();

                this.rptDiffSpecML.DataSource = lstSizeChartGroup;
                this.rptDiffSpecML.DataBind();

                this.dvDiffrence.Visible = true;
            }
        }

        private void Repopulate()
        {
            this.legPattern02.Visible = false;
            this.dvComparePattern.Visible = false;

            this.legDiffrence.Visible = false;
            this.dvDiffrence.Visible = false;
        }

        #endregion

    }
}