using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Transactions;
using Telerik.Web.UI;
using Dapper;
using Indico.BusinessObjects;
using Indico.Common;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

namespace Indico
{
    public partial class ViewProductionPlanningDetails : IndicoPage
    {
        #region Fields

        private List<ProductionLineBO> lstProductionLines = null;

        #endregion

        #region Properties

        //public bool IsNotRefresh
        //{
        //    get
        //    {
        //        return (Session["IsPostBack"].ToString() == ViewState["IsPostBack"].ToString());
        //    }
        //}

        protected List<ProductionLineBO> ProductionLines
        {
            get
            {
                if (Session["ListProductionLineBO"] != null)
                {
                    lstProductionLines = (List<ProductionLineBO>)Session["ListProductionLineBO"];
                }
                else
                {
                    lstProductionLines = (new ProductionLineBO()).GetAllObject().ToList();

                    Session["ListProductionLineBO"] = lstProductionLines;
                }
                return lstProductionLines;
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

        protected void rgProdPlans_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void rgProdPlans_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void rgProdPlans_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if (item.ItemIndex > -1 && item.DataItem is ReturnProductionPlanningDetailsViewBO)
                {
                    ReturnProductionPlanningDetailsViewBO objPlan = (ReturnProductionPlanningDetailsViewBO)item.DataItem;

                    DropDownList ddlProductionLine = (DropDownList)item.FindControl("ddlProductionLine");
                    TextBox txtSewingDate = (TextBox)item.FindControl("txtSewingDate");
                    Literal litPriority = (Literal)item.FindControl("litPriority");

                    litPriority.Text = (objPlan.FOCPenalty ?? false) ? "<span style='color:red; background-color:yellow'>CANNOT DELAY</span>" : string.Empty;

                    ddlProductionLine.Items.Clear();
                    ddlProductionLine.Items.Add(new ListItem("Select Production Line", "0"));
                    foreach (ProductionLineBO line in this.ProductionLines)
                    {
                        ddlProductionLine.Items.Add(new ListItem(line.Name, line.ID.ToString()));
                    }

                    ddlProductionLine.Items.FindByValue((objPlan.ProductionLine ?? 0).ToString()).Selected = true;
                    txtSewingDate.Text = (objPlan.SewingDate.Value == new DateTime(1900, 1, 1)) ? string.Empty : Convert.ToDateTime(objPlan.SewingDate).ToString("MMM dd, yyyy");

                    LinkButton btnSave = (LinkButton)item.FindControl("btnSave");
                    btnSave.Attributes.Add("od", objPlan.OrderDetail.ToString());
                    btnSave.Attributes.Add("wpc", objPlan.WeeklyProductionCapacity.ToString());
                }
            }
        }

        protected void rgProdPlans_ItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                this.ReBindGrid();
            }
            else if (e.CommandName == "Save")
            {
                try
                {
                    LinkButton btnSave = (LinkButton)e.Item.FindControl("btnSave");
                    DropDownList ddlProductionLine = (DropDownList)e.Item.FindControl("ddlProductionLine");
                    TextBox txtSewingDate = (TextBox)e.Item.FindControl("txtSewingDate");

                    int odID = int.Parse(btnSave.Attributes["od"].ToString());
                    int wpcID = int.Parse(btnSave.Attributes["wpc"].ToString());
                    int prodLine = int.Parse(ddlProductionLine.SelectedValue.ToString());
                    DateTime sewingDate = new DateTime(1900, 1, 1);
                    DateTime.TryParse(txtSewingDate.Text, out sewingDate);

                    //ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                    //objReturnInt = ProductionPlanningBO.UpdateProductionPlan(wpcID, odID, prodLine, sewingDate);

                    int objReturnInt = 0;

                    System.Data.SqlClient.SqlConnection connection = new System.Data.SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString);
                    connection.Open();
                    string query = string.Format(@"EXEC [Indico].[dbo].[SPC_UpdateProductionPlanning] '{0}','{1}','{2}','{3}'",
                                                                                          wpcID, odID, prodLine, sewingDate);
                    var result = connection.Query<int>(query);
                    connection.Close();

                    objReturnInt = result.First();

                    if (objReturnInt == 0)                    
                    {
                        IndicoLogging.log.Error("btnSave_Click : Error occured while saving on ViewProductionPlanningDetails.aspx, SPC_UpdateProductionPlanning ");
                    }
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("btnSave_Click : Error occured while saving on ViewProductionPlanningDetails.aspx", ex);
                }
            }
        }

        protected void rgProdPlans_SortCommand(object sender, GridSortCommandEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void HeaderContextMenu_ItemCLick(object sender, RadMenuEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void btnSaveAll_Click(object sender, EventArgs e)
        {
            foreach (GridItem item in this.rgProdPlans.Items)
            {
                try
                {
                    LinkButton btnSave = (LinkButton)item.FindControl("btnSave");
                    DropDownList ddlProductionLine = (DropDownList)item.FindControl("ddlProductionLine");
                    TextBox txtSewingDate = (TextBox)item.FindControl("txtSewingDate");

                    int odID = int.Parse(btnSave.Attributes["od"].ToString());
                    int wpcID = int.Parse(btnSave.Attributes["wpc"].ToString());
                    int prodLine = int.Parse(ddlProductionLine.SelectedValue.ToString());
                    DateTime sewingDate = new DateTime(1900, 1, 1);
                    DateTime.TryParse(txtSewingDate.Text, out sewingDate);

                    //ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                    //objReturnInt = ProductionPlanningBO.UpdateProductionPlan(wpcID, odID, prodLine, sewingDate);

                    int objReturnInt = 0;

                    System.Data.SqlClient.SqlConnection connection = new System.Data.SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString);
                    connection.Open();
                    string query = string.Format(@"EXEC [Indico].[dbo].[SPC_UpdateProductionPlanning] '{0}','{1}','{2}','{3}'",
                                                                                          wpcID, odID, prodLine, sewingDate);
                    var result = connection.Query<int>(query);
                    connection.Close();

                    objReturnInt = result.First();

                    if (objReturnInt == 0)
                    {
                        IndicoLogging.log.Error("btnSave_Click : Error occured while saving on ViewProductionPlanningDetails.aspx, SPC_UpdateProductionPlanning ");
                    }
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("btnSave_Click : Error occured while saving on ViewProductionPlanningDetails.aspx", ex);
                }
            }
        }

        protected void ddlWeek_SelectedIndexChanged(object sender, EventArgs e)
        {
            int weekID = int.Parse(ddlWeek.SelectedValue.ToString());

            if (weekID > 0)
            {
                int year = int.Parse(ddlWeek.SelectedItem.Text.Split('/')[0]);
                int week = int.Parse(ddlWeek.SelectedItem.Text.Split('/')[1].Split(' ')[0]);
                this.PopulateDataGrid(week, year);
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

            List<WeeklyProductionCapacityBO> lstWeekCapacities = new WeeklyProductionCapacityBO().GetAllObject();

            ddlWeek.Items.Clear();
            ddlWeek.Items.Add(new ListItem("Select a Week", "0"));
            foreach (WeeklyProductionCapacityBO week in lstWeekCapacities)
            {
                ddlWeek.Items.Add(new ListItem(week.WeekendDate.Year + "/" + week.WeekNo + " (" + Convert.ToDateTime(week.WeekendDate).ToString("MMM dd, yyyy") + ")", week.ID.ToString()));
            }
        }

        private void PopulateDataGrid(int week, int year)
        {
            //List<ReturnProductionPlanningDetailsViewBO> lstProdPlanDetais = ProductionPlanningBO.GetProductionPlans(week, year);

            List<ProductionPlanningDetailsView> lstProdPlanDetais = new List<ProductionPlanningDetailsView>();

            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString))
            {
                connection.Open();

                lstProdPlanDetais = connection.Query<ProductionPlanningDetailsView>(string.Format(@"EXEC [Indico].[dbo].[SPC_GetProductionPlanningDetails] '{0}','{1}'", week, year)).ToList();
                connection.Close();
            }

            if (lstProdPlanDetais.Count > 0)
            {
                this.rgProdPlans.AllowPaging = (lstProdPlanDetais.Count > this.rgProdPlans.PageSize);
                this.rgProdPlans.DataSource = lstProdPlanDetais;
                this.rgProdPlans.DataBind();
                Session["ProductionPlanningDetails"] = lstProdPlanDetais;

                this.btnSaveAll.Visible = true;
                this.dvDataContent.Visible = true;
                this.dvEmptyContent.Visible = false;
            }
            else
            {
                this.btnSaveAll.Visible = false;
                this.dvDataContent.Visible = false;
                this.dvEmptyContent.Visible = true;
            }
        }

        private void ReBindGrid()
        {
            if (Session["ProductionPlanningDetails"] != null)
            {
                rgProdPlans.DataSource = (List<ReturnProductionPlanningDetailsViewBO>)Session["ProductionPlanningDetails"];
                rgProdPlans.DataBind();
            }
        }

        //public DataSet GetDataSet()
        //{
        //    try
        //    {
        //        SqlConnection conn = new SqlConnection(@"Server=KIARA-PC\SQLEXPRESS;Database=Indico;Trusted_Connection=True;");

        //        using (SqlCommand cmd = new SqlCommand())
        //        {
        //            cmd.Connection = conn;
        //            cmd.CommandType = CommandType.StoredProcedure;
        //            cmd.CommandText = "SPC_GetProductionPlanningDetails";

        //            cmd.Parameters.Add(new SqlParameter("@P_Week", SqlDbType.Int)).Value = 10;
        //            cmd.Parameters.Add(new SqlParameter("@P_Year", SqlDbType.Int)).Value = 2016;

        //            using (SqlDataAdapter da = new SqlDataAdapter(cmd))
        //            {
        //                // Fill the DataSet using default values for DataTable names, etc
        //                DataSet dataset = new DataSet();
        //                da.Fill(dataset);

        //                conn.Close();
        //                return dataset;
        //            }
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        return null;
        //    }
        //}

        #endregion

        #region inner class

        private class ProductionPlanningDetailsView
        {
            public int WeeklyProductionCapacity { get; set; }
            public string Week { get; set; }
            public int OrderDetail { get; set; }
            public string Pattern { get; set; }
            public string OrderType { get; set; }
            public string PurchaseOrder { get; set; }
            public string Product { get; set; }
            public int Quantity { get; set; }
            public decimal SMV { get; set; }
            public decimal TotalSMV { get; set; }
            public string Client { get; set; }
            public string Mode { get; set; }
            public string ShipTo { get; set; }
            public string Port { get; set; }
            public string Country { get; set; }
            public int ProductionLine { get; set; }
            public DateTime SewingDate { get; set; }
            public bool FOCPenalty { get; set; }
        }

        #endregion
    }
}