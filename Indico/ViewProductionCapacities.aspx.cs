using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic;
using System.Transactions;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using Telerik.Web.UI;

using Indico.BusinessObjects;
using Indico.Common;
using System.Globalization;
using System.Drawing;

namespace Indico
{
    public partial class ViewProductionCapacities : IndicoPage
    {
        #region Fields

        #endregion

        #region Properties

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["ItemsAttributeSortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "WeekendDate";
                }
                return sort;
            }
            set
            {
                ViewState["ItemsAttributeSortExpression"] = value;
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

        #region Events

        /// <summary>
        /// Page load event.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>

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

        protected void RadGridProductionCapacities_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridProductionCapacities_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridProductionCapacities_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if (item.ItemIndex > -1 && item.DataItem is WeeklyProductionCapacityBO)
                {
                    var objProductionCapacity = (WeeklyProductionCapacityBO)item.DataItem;

                    var lblWeekNumber = (Label)item.FindControl("lblWeekNumber");
                    lblWeekNumber.Text = objProductionCapacity.WeekNo + "-" + objProductionCapacity.WeekendDate.Year;
                    var day = objProductionCapacity.WeekendDate.DayOfYear;
                    if(DateTime.Now.Year == objProductionCapacity.WeekendDate.Year && (DateTime.Now.DayOfYear<=day && DateTime.Now.DayOfYear>=day-6))
                        item.BackColor = Color.Orange;

                    var linkEdit = (HtmlAnchor)item.FindControl("linkEdit");
                    linkEdit.Attributes.Add("qid", objProductionCapacity.ID.ToString());

                    var litPoloProdCap = (Literal)item.FindControl("litPoloProdCap");
                    var litPolo5PcsCap = (Literal)item.FindControl("litPolo5PcsCap");
                    var litPoloSamplesCap = (Literal)item.FindControl("litPoloSamplesCap");
                    var litPoloWorkers = (Literal)item.FindControl("litPoloWorkers");
                    var litPoloEfficiency = (Literal)item.FindControl("litPoloEfficiency");

                    var litOuterProdCap = (Literal)item.FindControl("litOuterProdCap");
                    var litOuter5PcsCap = (Literal)item.FindControl("litOuter5PcsCap");
                    var litOuterSamplesCap = (Literal)item.FindControl("litOuterSamplesCap");
                    var litOuterWorkers = (Literal)item.FindControl("litOuterWorkers");
                    var litOuterEfficiency = (Literal)item.FindControl("litOuterEfficiency");

                    var objProdCapDetail = new WeeklyProductionCapacityDetailsBO {WeeklyProductionCapacity = objProductionCapacity.ID};
                    var lstDetails = objProdCapDetail.SearchObjects();

                    var objPolosDetail = lstDetails.FirstOrDefault(m => m.ItemType == 1);
                    var objOuterDetail = lstDetails.FirstOrDefault(m => m.ItemType == 2);

                    if (objPolosDetail != null)
                    {
                        litPoloProdCap.Text = string.Format("{0:N0}", objPolosDetail.TotalCapacity);
                        litPolo5PcsCap.Text = string.Format( "{0:N0}",objPolosDetail.FivePcsCapacity);
                        litPoloSamplesCap.Text = string.Format("{0:N0}", objPolosDetail.SampleCapacity);
                        litPoloWorkers.Text = string.Format("{0:N0}", objPolosDetail.Workers);
                        litPoloEfficiency.Text = string.Format("{0:N}", objPolosDetail.Efficiency);
                    }

                    if (objOuterDetail != null)
                    {
                        litOuterProdCap.Text = string.Format("{0:N0}", objOuterDetail.TotalCapacity);
                        litOuter5PcsCap.Text = string.Format("{0:N0}", objOuterDetail.FivePcsCapacity);
                        litOuterSamplesCap.Text = string.Format( "{0:N0}", objOuterDetail.SampleCapacity);
                        litOuterWorkers.Text = string.Format("{0:N0}", objOuterDetail.Workers);
                        litOuterEfficiency.Text = string.Format("{0:N}", objOuterDetail.Efficiency);
                    }

                    var i = 0;
                    foreach (TableCell cell in item.Cells)
                    {
                        if (i > 8 && i < 14)
                        {
                            cell.BackColor = Color.PowderBlue;
                        }
                        else if (i > 13 && i < 19)
                        {
                            cell.BackColor = Color.Moccasin;
                        }

                        i++;
                    }
                }
            }
        }

        protected void RadGridProductionCapacities_ItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                this.ReBindGrid();
            }
        }

        protected void RadGridProductionCapacities_SortCommand(object sender, GridSortCommandEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void HeaderContextMenu_ItemCLick(object sender, RadMenuEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            this.PopulateDataGrid();
            ViewState["IsPageValied"] = true;
        }

        protected void btnSaveChanges_Click(object sender, EventArgs e)
        {
            int itemId = int.Parse(this.hdnSelectedProductionCapacityID.Value.ToString().Trim());

            if (Page.IsValid)
            {
                this.ProcessForm(itemId, false);
                Response.Redirect("/ViewProductionCapacities.aspx");
            }
            else
            {
                WeeklyProductionCapacityBO objProductionCapacity = new WeeklyProductionCapacityBO();
                objProductionCapacity.ID = itemId;
                objProductionCapacity.GetObject();
                lblWeekNo.Text = objProductionCapacity.WeekNo + "_" + objProductionCapacity.WeekendDate.Year;
                lblFridayOfWeekPop.Text = objProductionCapacity.WeekendDate.ToString("dd/MM/yyy");

                ViewState["IsPageValied"] = (Page.IsValid);
                this.validationSummary.Visible = !(Page.IsValid);
            }
        }

        protected void btnNewCorrectDates_Click(object sender, EventArgs e)
        {
            for (int j= 2013; j <= 2018; j++)
            {
                bool isLeap = false;
                string currentYear = j.ToString();

                List<WeeklyProductionCapacityBO> lstWeeklyProdCap = (new WeeklyProductionCapacityBO()).SearchObjects();

                DateTime dFirst = DateTime.Parse("01 / 01 /" + currentYear);
                DateTime dLast = DateTime.Parse("31 / 12 /" + currentYear);
                if ((int.Parse(currentYear) % 4 == 0) && (int.Parse(currentYear) % 100 != 0) || (int.Parse(currentYear) % 400 == 0))
                {
                    isLeap = true;
                }

                int weekCount = (isLeap == true) ? this.GetWeeksInYear(int.Parse(currentYear), dLast) : int.Parse((dLast.Subtract(dFirst).Days / 7).ToString());
                DateTime firstTuesday = dFirst;
                while (firstTuesday.DayOfWeek != DayOfWeek.Tuesday)
                {
                    firstTuesday = firstTuesday.AddDays(1);
                }

                DateTime firstFriday = dFirst;
                while (firstFriday.DayOfWeek != DayOfWeek.Friday)
                {
                    firstFriday = firstFriday.AddDays(1);
                }

                for (int i = 1; i <= weekCount; i++)
                {
                    WeeklyProductionCapacityBO objProductionCapacity = new WeeklyProductionCapacityBO(this.ObjContext);
                    foreach (WeeklyProductionCapacityBO k in objProductionCapacity.GetAllObject())
                    {
                        if (k.WeekNo == i && k.WeekendDate.Year == firstFriday.Year && k.WeekendDate.Month == firstFriday.Month && k.WeekendDate.Day == firstFriday.Day)
                        {
                            WeeklyProductionCapacityBO update = new WeeklyProductionCapacityBO(this.ObjContext);
                            update.ID = k.ID;
                            update.GetObject();

                            update.WeekendDate = firstTuesday;
                            this.ObjContext.SaveChanges();
                            break;
                        }
                    }

                    firstTuesday = firstTuesday.AddDays(7);
                    firstFriday = firstFriday.AddDays(7);
                }
            }
        }

        protected void btnNewProductionCapacity_Click(object sender, EventArgs e)
        {
           AddNextYear();
        }

        protected void ddlYear_SelectedIndexChanged(object sender, EventArgs e)
        {
            PopulateDataGrid();
        }

        protected void ddlMonth_SelectedIndexChanged(object sender, EventArgs e)
        {
            PopulateDataGrid();
        }

        protected void linkSave_ServerClick(object sender, EventArgs e)
        {
            if (!IsNotRefresh)
                return;
            try
            {
                using (var ts = new TransactionScope())
                {
                    foreach (GridDataItem item in this.RadGridProductionCapacities.Items)
                    {
                        var linkSave = (HtmlAnchor)item.FindControl("linkSave");

                        var txtCapacity = (TextBox)item.FindControl("txtCapacity");

                        var txtHoliydays = (TextBox)item.FindControl("txtHoliydays");

                        var txtNotes = (TextBox)item.FindControl("txtNotes");

                        var txtSalesTarget = (TextBox)item.FindControl("txtSalesTarget");

                        var id = int.Parse(((System.Web.UI.HtmlControls.HtmlControl)(linkSave)).Attributes["pcid"].ToString());

                        if (id <= 0)
                            continue;
                        var objProductionCapacity = new WeeklyProductionCapacityBO(ObjContext) {ID = id};
                        objProductionCapacity.GetObject();

                        objProductionCapacity.Capacity = int.Parse(txtCapacity.Text.Replace(",", string.Empty));
                        objProductionCapacity.NoOfHolidays = (!string.IsNullOrEmpty(txtHoliydays.Text)) ? int.Parse(txtHoliydays.Text) : 0;
                        objProductionCapacity.Notes = txtNotes.Text;
                        objProductionCapacity.SalesTarget = Convert.ToDecimal(txtSalesTarget.Text);
                    }

                    ObjContext.SaveChanges();
                    ts.Complete();
                }

            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while updaing Production Capacities Details in ViewProductionCapacities.aspx", ex);
            }

            PopulateDataGrid();
        }

        protected void btnCalulate_ServerClick(object sender, EventArgs e)
        {
            PopulateDataGrid();
        }

        protected void rptItemTypes_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            var item = e.Item;
            if (item.ItemIndex <= -1 || !(item.DataItem is KeyValuePair<ItemTypeBO, KeyValuePair<WeeklyProductionCapacityBO, WeeklyProductionCapacityDetailsBO>>))
                return;
            var objCapacityDetail = (KeyValuePair<ItemTypeBO, KeyValuePair<WeeklyProductionCapacityBO, WeeklyProductionCapacityDetailsBO>>)item.DataItem;
            var objCapDetail = objCapacityDetail.Value.Value;
            var objCap = objCapacityDetail.Value.Key;

            if (objCapDetail == null)
                return;
            var litItemType = (Literal)item.FindControl("litItemType");
            var txtTotalCapacity = (TextBox)item.FindControl("txtTotalCapacity");
            var txt5PcsCapacity = (TextBox)item.FindControl("txt5PcsCapacity");
            var txtSampleCapacity = (TextBox)item.FindControl("txtSampleCapacity");
            var txtWorkers = (TextBox)item.FindControl("txtWorkers");
            var txtEfficiency = (TextBox)item.FindControl("txtEfficiency");
            var hdnProdCapDetailID = (HiddenField)item.FindControl("hdnProdCapDetailID");
            var hdnItemTypeID = (HiddenField)item.FindControl("hdnItemTypeID");
            var txtTotalCapacityWeek = (TextBox)item.FindControl("txtTotalCapacityWeek");
            var txt5PcsCapacityWeek = (TextBox)item.FindControl("txt5PcsCapacityWeek");
            var txtSampleCapacityWeek = (TextBox)item.FindControl("txtSampleCapacityWeek");

            litItemType.Text = objCapacityDetail.Key.Name;
            hdnItemTypeID.Value = objCapacityDetail.Key.ID.ToString();

            hdnProdCapDetailID.Value = objCapDetail.ID.ToString();
            txtTotalCapacity.Text = Math.Round(objCapDetail.TotalCapacity.GetValueOrDefault()/objCap.NoOfHolidays,2).ToString();
            txt5PcsCapacity.Text = Math.Round(objCapDetail.FivePcsCapacity.GetValueOrDefault() / objCap.NoOfHolidays,2).ToString();
            txtSampleCapacity.Text = Math.Round(objCapDetail.SampleCapacity.GetValueOrDefault() / objCap.NoOfHolidays,2).ToString();
            txtTotalCapacityWeek.Text = decimal.ToInt32(objCapDetail.TotalCapacity.GetValueOrDefault()).ToString();
            txt5PcsCapacityWeek.Text = decimal.ToInt32(objCapDetail.FivePcsCapacity.GetValueOrDefault()).ToString();
            txtSampleCapacityWeek.Text = decimal.ToInt32(objCapDetail.SampleCapacity.GetValueOrDefault()).ToString();
            txtWorkers.Text = objCapDetail.Workers.ToString();
            txtEfficiency.Text = objCapDetail.Efficiency.ToString();
        }

        protected void linkEdit_ServerClick(object sender, EventArgs e)
        {
            int proCapID = int.Parse(hdnSelectedProductionCapacityID.Value);
            PopulateProductionCapacityDetails(proCapID);
        }

        #endregion

        #region Methods

        /// <summary>
        /// Populate the controls.
        /// </summary>
        private void PopulateControls()
        {
            //Header Text
            this.litHeaderText.Text = ActivePage.Heading;
            // Popup Header Text
            lblPopupHeaderText.Text = "Edit Production Capacities";

            //Set validity of the control fields
            ViewState["IsPageValid"] = true;
            ViewState["IsPopulateModel"] = false;

            ddlYear.Items.Clear();
            //ddlYear.Items.Add(new ListItem("All", "0"));
            List<int> lstYears = (new WeeklyProductionCapacityBO()).SearchObjects().Select(o => o.WeekendDate.Year).Distinct().ToList();
            foreach (int year in lstYears)
            {
                ddlYear.Items.Add(new ListItem(year.ToString()));
            }

            var exists = lstYears.Contains(DateTime.Now.Year);

            if (exists)
            {
                ddlYear.Items.FindByValue(DateTime.Now.Year.ToString()).Selected = true;
            }
            else
            {
                ddlYear.Items.FindByValue("0").Selected = true;
            }

            ddlMonth.Items.Clear();
            //ddlMonth.Items.Add(new ListItem("All", "0"));
            var lstMonths = (new WeeklyProductionCapacityBO()).SearchObjects().Select(o => o.WeekendDate.Month).Distinct().ToList();
            foreach (var month in lstMonths)
            {
                var monthname = CultureInfo.CurrentCulture.DateTimeFormat.GetMonthName(month);
                ddlMonth.Items.Add(new ListItem(monthname, month.ToString()));
            }

            ddlMonth.Items.FindByValue(DateTime.Now.Month.ToString()).Selected = true;

            Session["WeeklyProductionCapacity"] = null;

            PopulateDataGrid();
        }

        private void ProcessForm(int queryId, bool isDelete)
        {
            try
            {
                using (var ts = new TransactionScope())
                {
                    var objProductionCapacity = new WeeklyProductionCapacityBO(ObjContext);
                    if (queryId > 0)
                    {
                        objProductionCapacity.ID = queryId;
                        objProductionCapacity.GetObject();
                    }
                    if (isDelete)
                        objProductionCapacity.Delete();

                    else
                    {
                        objProductionCapacity.NoOfHolidays = int.Parse(txtWorkingDays.Text);
                        objProductionCapacity.HoursPerDay = decimal.Parse(txtWorkingHours.Text);
                        objProductionCapacity.OrderCutOffDate = DateTime.Parse(txtOrderCutOffDate.Text);
                        objProductionCapacity.EstimatedDateOfDespatch = DateTime.Parse(txtETD.Text);
                        objProductionCapacity.EstimatedDateOfArrival = DateTime.Parse(txtETA.Text);
                        objProductionCapacity.Notes = txtNotes.Text;
                        objProductionCapacity.SalesTarget = decimal.Parse(txtSalesTaget.Text);

                        foreach (RepeaterItem rptItem in rptItemTypes.Items)
                        {
                            var hdnProdCapDetailID = (HiddenField)rptItem.FindControl("hdnProdCapDetailID");
                            var hdnItemTypeID = (HiddenField)rptItem.FindControl("hdnItemTypeID");
                            var txtTotalCapacity = (TextBox)rptItem.FindControl("txtTotalCapacity");
                            var txt5PcsCapacity = (TextBox)rptItem.FindControl("txt5PcsCapacity");
                            var txtSampleCapacity = (TextBox)rptItem.FindControl("txtSampleCapacity");
                            var txtWorkers = (TextBox)rptItem.FindControl("txtWorkers");
                            var txtEfficiency = (TextBox)rptItem.FindControl("txtEfficiency");
                            var objProdCapDetailBO = new WeeklyProductionCapacityDetailsBO(ObjContext);
                            if (int.Parse(hdnProdCapDetailID.Value) > 0)
                            {
                                objProdCapDetailBO.ID = int.Parse(hdnProdCapDetailID.Value);
                                objProdCapDetailBO.GetObject();
                            }
                            else
                            {
                                objProdCapDetailBO.WeeklyProductionCapacity = queryId;
                                objProdCapDetailBO.ItemType = int.Parse(hdnItemTypeID.Value);
                            }
                            objProdCapDetailBO.TotalCapacity = int.Parse(txtTotalCapacity.Text) * objProductionCapacity.NoOfHolidays;
                            objProdCapDetailBO.FivePcsCapacity = int.Parse(txt5PcsCapacity.Text) * objProductionCapacity.NoOfHolidays;
                            objProdCapDetailBO.SampleCapacity = int.Parse(txtSampleCapacity.Text) * objProductionCapacity.NoOfHolidays;
                            objProdCapDetailBO.Workers = int.Parse(txtWorkers.Text);
                            objProdCapDetailBO.Efficiency = decimal.Parse(txtEfficiency.Text);
                        }
                        if (queryId == 0)
                            objProductionCapacity.Add();
                    }
                    ObjContext.SaveChanges();
                    ts.Complete();
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occurred while Adding or Editing  or Deleting  the details in Production Capacity", ex);
            }
        }

        private void PopulateDataGrid()
        {
            // Hide Controls
            dvEmptyContent.Visible = false;
            dvDataContent.Visible = false;

            btnNewProductionCapacity.Visible = true;

            // get the first monday of the week
            var daysTillMonday = (int)DateTime.Today.DayOfWeek - (int)DayOfWeek.Monday;
            var monday = DateTime.Today.AddDays(-daysTillMonday);

            // get the first monday  of specific month
            DateTime dt = DateTime.Now;
            if (ddlMonth.SelectedIndex > -1 && ddlYear.SelectedIndex > -1)
            {
                dt = new DateTime(int.Parse(ddlYear.SelectedValue), int.Parse(ddlMonth.SelectedValue), 1);
                dt = dt.AddDays(1);
            }

            // Search text
            string searchText = txtSearch.Text.ToLower().Trim();

            // Populate Item Attribute
            WeeklyProductionCapacityBO objProductionCapacity = new WeeklyProductionCapacityBO();

            // Sort by condition
            List<WeeklyProductionCapacityBO> lstProductionCapacity = new List<WeeklyProductionCapacityBO>();
            if ((searchText != string.Empty) && (searchText != "search"))
            {
                lstProductionCapacity = (from o in objProductionCapacity.SearchObjects().AsQueryable().Where(o => o.WeekendDate >= monday && o.WeekendDate.ToString().Contains(searchText))
                                         .OrderBy(SortExpression).ToList<WeeklyProductionCapacityBO>()
                                         select o).ToList();
            }
            else
            {
                if (ddlYear.SelectedIndex > -1)
                {
                    if (int.Parse(ddlMonth.SelectedValue) == DateTime.Now.Month)
                    {
                        lstProductionCapacity = objProductionCapacity.SearchObjects().AsQueryable().Where(o => o.WeekendDate >= monday && o.WeekendDate.Year >= int.Parse(ddlYear.SelectedItem.Text)).OrderBy(SortExpression).ToList<WeeklyProductionCapacityBO>();
                    }
                }
                else if (this.ddlYear.SelectedIndex == -1)
                {
                    lstProductionCapacity = objProductionCapacity.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList<WeeklyProductionCapacityBO>();
                }
                else
                {
                    lstProductionCapacity = objProductionCapacity.SearchObjects().AsQueryable().Where(o => o.WeekendDate.Date >= monday).OrderBy(SortExpression).ToList<WeeklyProductionCapacityBO>();
                }
            }

            if (this.ddlMonth.SelectedIndex > -1)
            {
                if (int.Parse(this.ddlMonth.SelectedValue) != DateTime.Now.Month)
                {
                    lstProductionCapacity = objProductionCapacity.SearchObjects().AsQueryable().Where(o => o.WeekendDate >= dt).OrderBy(o => o.WeekendDate).ToList<WeeklyProductionCapacityBO>();
                }
            }
            else if (this.ddlMonth.SelectedIndex == -1)
            {
                lstProductionCapacity = lstProductionCapacity.ToList<WeeklyProductionCapacityBO>();
            }

            if (lstProductionCapacity.Count > 0)
            {
                RadGridProductionCapacities.AllowPaging = (lstProductionCapacity.Count > RadGridProductionCapacities.PageSize);
                RadGridProductionCapacities.DataSource = lstProductionCapacity;
                RadGridProductionCapacities.DataBind();
                Session["WeeklyProductionCapacity"] = lstProductionCapacity;

                dvDataContent.Visible = true;
            }
            else if ((searchText != string.Empty && searchText != "search") || (ddlYear.SelectedIndex > -1) || (ddlMonth.SelectedIndex > -1))
            {
                lblSerchKey.Text = searchText + ((searchText != string.Empty) ? " - " : string.Empty);

                dvDataContent.Visible = true;
                dvNoSearchResult.Visible = true;
            }
            else
            {
                dvEmptyContent.Visible = true;
                btnNewProductionCapacity.Visible = true;
            }
            //change btnNewProductionCapacity button Text
            List<WeeklyProductionCapacityBO> lstWeeklyProdCap = (new WeeklyProductionCapacityBO()).SearchObjects();
            if (lstWeeklyProdCap.Count == 0)
            {
                btnNewProductionCapacity.InnerText = "Add weeks for year " + DateTime.Now.Year.ToString();
                lblDataAdded.Text = "Weeks until December " + DateTime.Now.Year.ToString();
            }
            if (lstWeeklyProdCap.Count > 0)
            {
                btnNewProductionCapacity.InnerText = "Add weeks for year " + lstWeeklyProdCap.Last().WeekendDate.AddYears(1).Year;
                lblDataAdded.Text = "Weeks until December " + lstWeeklyProdCap.Last().WeekendDate.Year.ToString();
            }

            RadGridProductionCapacities.Visible = (lstProductionCapacity.Count > 0);
        }

        private int GetWeeksInYear(int year, DateTime lastDayofYear)
        {
            DateTimeFormatInfo dfi = DateTimeFormatInfo.CurrentInfo;
            //DateTime date1 = new DateTime(year, 12, 31);
            System.Globalization.Calendar cal = dfi.Calendar;
            return cal.GetWeekOfYear(lastDayofYear, dfi.CalendarWeekRule, dfi.FirstDayOfWeek);
        }

        private void ReBindGrid()
        {
            if (Session["WeeklyProductionCapacity"] != null)
            {
                RadGridProductionCapacities.DataSource = (List<WeeklyProductionCapacityBO>)Session["WeeklyProductionCapacity"];
                RadGridProductionCapacities.DataBind();
            }
        }

        //last modified by - rusith
        private void PopulateProductionCapacityDetails(int proCapID)
        {
            if (IsNotRefresh)
            {
                var objProCap = new WeeklyProductionCapacityBO();
                objProCap.ID = proCapID;
                objProCap.GetObject();

                lblWeekNo.Text = objProCap.WeekNo + "-" + objProCap.WeekendDate.Year;
                lblFridayOfWeekPop.Text = objProCap.WeekendDate.ToString("dd MMMM yyyy");

                this.txtWorkingDays.Text = objProCap.NoOfHolidays.ToString();
                txtWorkingHours.Text = objProCap.HoursPerDay.ToString();
                txtOrderCutOffDate.Text = objProCap.OrderCutOffDate.HasValue ? objProCap.OrderCutOffDate.Value.ToString("dd MMMM yyyy") : string.Empty;
                txtETD.Text = objProCap.EstimatedDateOfDespatch.HasValue ? objProCap.EstimatedDateOfDespatch.Value.ToString("dd MMMM yyyy") : string.Empty;
                txtETA.Text = objProCap.EstimatedDateOfArrival.HasValue ? objProCap.EstimatedDateOfArrival.Value.ToString("dd MMMM yyyy") : string.Empty;
                txtNotes.Text = objProCap.Notes;
                txtSalesTaget.Text = objProCap.SalesTarget.GetValueOrDefault().ToString();

                var objCapacity = new WeeklyProductionCapacityDetailsBO {WeeklyProductionCapacity = proCapID};
                var lstCapDetails = objCapacity.SearchObjects();
                var lstTypes = (new ItemTypeBO()).SearchObjects();

                var lstProductCapacityDetails = lstTypes.Select(objType => new KeyValuePair<ItemTypeBO, KeyValuePair<WeeklyProductionCapacityBO,WeeklyProductionCapacityDetailsBO>>(objType, new KeyValuePair<WeeklyProductionCapacityBO, WeeklyProductionCapacityDetailsBO>(objProCap, lstCapDetails.FirstOrDefault(m => m.ItemType == objType.ID)))).ToList();

                rptItemTypes.DataSource = lstProductCapacityDetails;
                rptItemTypes.DataBind();
                ViewState["IsPopulateModel"] = true;
            }
            else
            {
                ViewState["IsPopulateModel"] = false;
                ViewState["IsPageValid"] = true;
            }
        }

        private void AddNextYear()
        {

            using (var scope = new TransactionScope())
            {
                var currentYear = DateTime.Now.Year;

                var currentWeeks = new WeeklyProductionCapacityBO(ObjContext).GetAllObject();
                if (currentWeeks.Any())
                {
                    if (currentWeeks.Count > 1)
                    {
                        var lastWeek = currentWeeks.OrderBy(w=>w.WeekendDate).Last().WeekendDate;
                        currentYear = lastWeek.Year == currentWeeks[currentWeeks.Count() - 2].WeekendDate.Year ?
                                                                                                    lastWeek.AddYears(1).Year : lastWeek.Year;
                    }
                    else currentYear = currentWeeks.Last().WeekendDate.AddYears(1).Year;
                }
                var currentYearStartDate = new DateTime(currentYear, 1, 1);
                while (currentYearStartDate.DayOfWeek != DayOfWeek.Tuesday)
                {
                    currentYearStartDate = currentYearStartDate.AddDays(1);
                }
                var weekNumber = 1;
                while (currentYearStartDate.Year == currentYear)
                {
                    var weeklyProductionCapacity = new WeeklyProductionCapacityBO(ObjContext) { WeekNo = weekNumber, WeekendDate = currentYearStartDate,SalesTarget = 0,HoursPerDay = (decimal)10.0,NoOfHolidays = 6,OrderCutOffDate = currentYearStartDate.AddDays(-18),EstimatedDateOfDespatch = currentYearStartDate,EstimatedDateOfArrival = currentYearStartDate.AddDays(3)};

                    weeklyProductionCapacity.Add();

                    var polodetails = new WeeklyProductionCapacityDetailsBO(ObjContext) {ItemType = 1, TotalCapacity = 5850, FivePcsCapacity = 100, SampleCapacity = 200, Workers = 65, Efficiency = (decimal) 0.45};
                    var outerwaredetails = new WeeklyProductionCapacityDetailsBO(ObjContext) {ItemType = 2, TotalCapacity = 450, FivePcsCapacity = 10, SampleCapacity = 20, Workers = 15, Efficiency = (decimal)0.25};
                    weeklyProductionCapacity.WeeklyProductionCapacityDetailssWhereThisIsWeeklyProductionCapacity.Add(polodetails);
                    weeklyProductionCapacity.WeeklyProductionCapacityDetailssWhereThisIsWeeklyProductionCapacity.Add(outerwaredetails);
                    currentYearStartDate = currentYearStartDate.AddDays(7);
                    weekNumber++;
                }
                ObjContext.SaveChanges();
                scope.Complete();
            }
            PopulateDataGrid();


            //try
            //{
            //    using (var ts = new TransactionScope())
            //    {
            //        var currentYear = DateTime.Now.Year.ToString();
            //        bool isLeap = false;


            //        List<WeeklyProductionCapacityBO> lstWeeklyProdCap = (new WeeklyProductionCapacityBO()).SearchObjects();
            //        if (lstWeeklyProdCap.Count > 0)
            //        {
            //            currentYear = lstWeeklyProdCap.Last().WeekendDate.AddYears(1).Year.ToString();
            //        }

            //        DateTime dFirst = DateTime.Parse("01 / 01 /" + currentYear);
            //        DateTime dLast = DateTime.Parse("31 / 12 /" + currentYear);

            //        if ((int.Parse(currentYear) % 4 == 0) && (int.Parse(currentYear) % 100 != 0) || (int.Parse(currentYear) % 400 == 0))
            //        {
            //            isLeap = true;
            //        }

            //        int weekCount = (isLeap == true) ? this.GetWeeksInYear(int.Parse(currentYear), dLast) : int.Parse((dLast.Subtract(dFirst).Days / 7).ToString());
            //        //int id = this.GetWeeksInYear(int.Parse(currentYear), dLast);

            //        DateTime firstTuesday = dFirst;

            //        while (firstTuesday.DayOfWeek != DayOfWeek.Tuesday)
            //        {
            //            firstTuesday = firstTuesday.AddDays(1);
            //        }

            //        for (int i = 1; i <= weekCount; i++)
            //        {
            //            WeeklyProductionCapacityBO objProductionCapacity = new WeeklyProductionCapacityBO(this.ObjContext);
            //            objProductionCapacity.WeekNo = i;
            //            objProductionCapacity.WeekendDate = firstTuesday;
            //            objProductionCapacity.Capacity = 0;
            //            objProductionCapacity.Add();

            //            firstTuesday = firstTuesday.AddDays(7);
            //        }

            //        this.ObjContext.SaveChanges();
            //        ts.Complete();
            //    }
            //}
            //catch (Exception)
            //{
            //    //ignored
            //}

        }

        #endregion

        protected void OnAddNextYearButtonClick(object sender, EventArgs e)
        {
            AddNextYear();
        }
    }
}