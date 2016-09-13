using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Transactions;
using Telerik.Web.UI;

using Indico.BusinessObjects;
using Indico.Common;
using System.Globalization;

namespace Indico
{
    public partial class ViewBackOrders : IndicoPage
    {
        #region Fields

        #endregion

        #region Properties

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["BackOrderSortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "Distributor";
                }
                return sort;
            }
            set
            {
                ViewState["BackOrderSortExpression"] = value;
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
        /// 
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

        protected void RadGridBackOrders_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridBackOrders_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridBackOrders_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if (item.ItemIndex > -1 && item.DataItem is ReturnBackOrdersViewBO)
                {
                    ReturnBackOrdersViewBO objReturnBackOrdersView = (ReturnBackOrdersViewBO)item.DataItem;

                    TextBox txtCoordinatorEmail = (TextBox)item.FindControl("txtCoordinatorEmail");
                    txtCoordinatorEmail.Text = objReturnBackOrdersView.CoordinatorEmailAddress.Trim();

                    TextBox txtDistributorEmail = (TextBox)item.FindControl("txtDistributorEmail");
                    txtDistributorEmail.Text = objReturnBackOrdersView.DistributorEmailAddress.Trim();

                    Literal litEmailSent = (Literal)item.FindControl("litEmailSent");
                    litEmailSent.Text = ((int)objReturnBackOrdersView.Count > 0) ? "Yes ( " + objReturnBackOrdersView.Count + " )" : "No";

                    var daysTillfriday = (int)DayOfWeek.Friday - (int)DateTime.Today.DayOfWeek;
                    var friday = DateTime.Today.AddDays(daysTillfriday);

                    int wpid = (new WeeklyProductionCapacityBO()).SearchObjects().Where(o => o.WeekendDate == friday).Select(o => o.ID).SingleOrDefault();

                    DistributorSendMailCountBO objSendMail = new DistributorSendMailCountBO();
                    objSendMail.Distributor = (int)objReturnBackOrdersView.DistributorID;
                    objSendMail.WeeklyProductionCapacity = wpid;

                    int sendmail = objSendMail.SearchObjects().Select(o => o.ID).SingleOrDefault();

                    HiddenField hdnWeekLyID = (HiddenField)item.FindControl("hdnWeekLyID");
                    hdnWeekLyID.Value = wpid.ToString();

                    HiddenField hdnSendMail = (HiddenField)item.FindControl("hdnSendMail");
                    hdnSendMail.Value = sendmail.ToString();

                    LinkButton btnSendMail = (LinkButton)item.FindControl("btnSendMail");
                    btnSendMail.Attributes.Add("wdate", friday.ToString());
                    btnSendMail.Attributes.Add("did", objReturnBackOrdersView.DistributorID.ToString());

                    LinkButton btnSave = (LinkButton)item.FindControl("btnSave");
                    btnSave.Attributes.Add("cid", objReturnBackOrdersView.CoordinatorID.ToString());
                    btnSave.Attributes.Add("did", objReturnBackOrdersView.DistributorID.ToString());

                    LinkButton btnDownloadBackOrder = (LinkButton)item.FindControl("btnDownloadBackOrder");
                    btnDownloadBackOrder.Attributes.Add("wdate", friday.ToString());
                    btnDownloadBackOrder.Attributes.Add("did", objReturnBackOrdersView.DistributorID.ToString());


                    //HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
                    //linkEdit.Attributes.Add("qid", objReturnBackOrdersView.ID.ToString());

                    //HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                    //linkDelete.Attributes.Add("qid", objReturnBackOrdersView.ID.ToString());
                    //linkDelete.Visible = (objReturnBackOrdersView.PatternsWhereThisIsAgeGroup.Count == 0);
                }
            }
        }

        protected void RadGridBackOrders_ItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                this.ReBindGrid();
            }
        }

        protected void RadGridBackOrders_SortCommand(object sender, GridSortCommandEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void HeaderContextMenu_ItemCLick(object sender, RadMenuEventArgs e)
        {
            this.ReBindGrid();
        }

        //protected void dataGridAgeGroup_ItemDataBound(object sender, DataGridItemEventArgs e)
        //{
        //    DataGridItem item = e.Item;
        //    if (item.ItemIndex > -1 && item.DataItem is ReturnBackOrdersViewBO)
        //    {
        //        ReturnBackOrdersViewBO objReturnBackOrdersView = (ReturnBackOrdersViewBO)item.DataItem;

        //        HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
        //        linkEdit.Attributes.Add("qid", objReturnBackOrdersView.ID.ToString());

        //        HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
        //        linkDelete.Attributes.Add("qid", objReturnBackOrdersView.ID.ToString());
        //        linkDelete.Visible = (objReturnBackOrdersView.PatternsWhereThisIsAgeGroup.Count == 0);
        //    }
        //}

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            ViewState["IsPageValied"] = true;
            this.PopulateDataGrid();
        }

        //protected void btnSaveChanges_Click(object sender, EventArgs e)
        //{
        //    if (this.IsNotRefresh)
        //    {
        //        int agegroupId = int.Parse(this.hdnSelectedAgeGroupID.Value.Trim());

        //        if (Page.IsValid)
        //        {
        //            this.ProcessForm(agegroupId, false);

        //            Response.Redirect("/ViewAgeGroups.aspx");
        //        }

        //        ViewState["IsPageValied"] = (Page.IsValid);
        //    }
        //}

        //protected void btnDelete_Click(object sender, EventArgs e)
        //{
        //    int agegroupId = int.Parse(this.hdnSelectedAgeGroupID.Value.Trim());

        //    if (!Page.IsValid)
        //    {
        //        this.ProcessForm(agegroupId, true);

        //        this.PopulateDataGrid();
        //    }

        //    ViewState["IsPageValied"] = (Page.IsValid);
        //    ViewState["IsPageValied"] = true;
        //    this.validationSummary.Visible = !(Page.IsValid);

        //}

        //protected void dataGridAgeGroup_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        //{
        //    // Set page index
        //    this.dataGridAgeGroup.CurrentPageIndex = e.NewPageIndex;

        //    this.PopulateDataGrid();
        //}

        //protected void dataGridAgeGroup_SortCommand(object source, DataGridSortCommandEventArgs e)
        //{
        //    string sortDirection = String.Empty;
        //    if (!SortExpression.ToUpper().StartsWith(e.SortExpression) && !SortExpression.ToUpper().Trim().EndsWith("ASC"))
        //    {
        //        sortDirection = " asc";
        //    }
        //    else
        //    {
        //        sortDirection = (SortExpression.ToUpper().EndsWith("DESC")) ? " asc" : " desc";
        //    }
        //    this.SortExpression = e.SortExpression + sortDirection;

        //    this.PopulateDataGrid();

        //    foreach (DataGridColumn col in this.dataGridAgeGroup.Columns)
        //    {
        //        if (col.Visible && col.SortExpression == e.SortExpression)
        //        {
        //            col.HeaderStyle.CssClass = "selected " + ((sortDirection.ToUpper() != " DESC") ? "sortDown" : "sortUp");
        //        }
        //        else
        //        {
        //            col.HeaderStyle.CssClass = "";
        //        }
        //    }
        //}

        protected void btnSendMail_Click(object sender, EventArgs e)
        {
            try
            {

                TextBox txtCoordinatorEmail = (TextBox)((LinkButton)(sender)).FindControl("txtCoordinatorEmail");

                TextBox txtDistributorEmail = (TextBox)((LinkButton)(sender)).FindControl("txtDistributorEmail");

                HiddenField hdnWeekLyID = (HiddenField)((LinkButton)(sender)).FindControl("hdnWeekLyID");

                HiddenField hdnSendMail = (HiddenField)((LinkButton)(sender)).FindControl("hdnSendMail");

                int distributor = int.Parse(((System.Web.UI.WebControls.WebControl)(sender)).Attributes["did"].ToString());

                DateTime WeekendDate = DateTime.Parse(((System.Web.UI.WebControls.WebControl)(sender)).Attributes["wdate"].ToString());

                if (!string.IsNullOrEmpty(txtCoordinatorEmail.Text) && !string.IsNullOrEmpty(txtDistributorEmail.Text) && distributor > 0 && WeekendDate != null)
                {
                    string pdfFilePath = Common.GenerateOdsPdf.GenerateBackOrder(WeekendDate, distributor);

                    string[] pdfPath = new string[] { pdfFilePath };

                    IndicoEmail.SendMail(this.LoggedCompany.Name, this.LoggedUser.EmailAddress, string.Empty, txtCoordinatorEmail.Text, txtDistributorEmail.Text, "Back Order Report", string.Empty, pdfPath, false, string.Empty);
                }

                int count = 0;

                using (TransactionScope ts = new TransactionScope())
                {
                    DistributorSendMailCountBO objSendMail = new DistributorSendMailCountBO(this.ObjContext);

                    if (int.Parse(hdnSendMail.Value.ToString())>0)
                    {
                        objSendMail.ID = int.Parse(hdnSendMail.Value.ToString());
                        objSendMail.GetObject();

                        count = (int)objSendMail.Count;
                    }

                    objSendMail.Distributor = distributor;
                    objSendMail.WeeklyProductionCapacity = int.Parse(hdnWeekLyID.Value.ToString());
                    count++;
                    objSendMail.Count = count;

                    this.ObjContext.SaveChanges();
                    ts.Complete();                   

                }

            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while sending email to the coordinator and distributor feom ViewBackOrders.aspx page", ex);
            }

            this.PopulateDataGrid();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            int coordinator = int.Parse(((System.Web.UI.WebControls.WebControl)(sender)).Attributes["cid"].ToString());

            int distributor = int.Parse(((System.Web.UI.WebControls.WebControl)(sender)).Attributes["did"].ToString());

            if (coordinator > 0 && distributor > 0)
            {
                try
                {
                    using (TransactionScope ts = new TransactionScope())
                    {
                        List<CoordinatorEmailAddressBO> lstCoordinatorEmailAddres = (new CoordinatorEmailAddressBO()).SearchObjects().Where(o => o.User == coordinator).ToList();

                        if (lstCoordinatorEmailAddres.Count > 0)
                        {
                            foreach (CoordinatorEmailAddressBO cea in lstCoordinatorEmailAddres)
                            {
                                CoordinatorEmailAddressBO objCoordinatorEmailAddress = new CoordinatorEmailAddressBO(this.ObjContext);
                                objCoordinatorEmailAddress.ID = cea.ID;
                                objCoordinatorEmailAddress.GetObject();

                                objCoordinatorEmailAddress.Delete();
                            }

                            this.ObjContext.SaveChanges();
                        }

                        List<DistributorEmailAddressBO> lstDistributorEmailAddres = (new DistributorEmailAddressBO()).SearchObjects().Where(o => o.Distributor == distributor).ToList();

                        if (lstDistributorEmailAddres.Count > 0)
                        {
                            foreach (DistributorEmailAddressBO dea in lstDistributorEmailAddres)
                            {
                                DistributorEmailAddressBO objDistributorEmailAddress = new DistributorEmailAddressBO(this.ObjContext);
                                objDistributorEmailAddress.ID = dea.ID;
                                objDistributorEmailAddress.GetObject();

                                objDistributorEmailAddress.Delete();
                            }

                            this.ObjContext.SaveChanges();
                        }

                        TextBox txtCoordinatorEmail = (TextBox)((LinkButton)(sender)).FindControl("txtCoordinatorEmail");

                        if (!string.IsNullOrEmpty(txtCoordinatorEmail.Text))
                        {
                            foreach (string email in txtCoordinatorEmail.Text.Split(','))
                            {
                                if (!string.IsNullOrEmpty(email))
                                {
                                    CoordinatorEmailAddressBO objCoordinatorEmailAddress = new CoordinatorEmailAddressBO(this.ObjContext);
                                    objCoordinatorEmailAddress.User = coordinator;
                                    objCoordinatorEmailAddress.EmailAddress = email.Trim();
                                }
                            }

                            this.ObjContext.SaveChanges();
                        }

                        TextBox txtDistributorEmail = (TextBox)((LinkButton)(sender)).FindControl("txtDistributorEmail");

                        if (!string.IsNullOrEmpty(txtDistributorEmail.Text))
                        {
                            foreach (string email in txtDistributorEmail.Text.Split(','))
                            {
                                if (!string.IsNullOrEmpty(email))
                                {
                                    DistributorEmailAddressBO objDistributorEmailAddress = new DistributorEmailAddressBO(this.ObjContext);
                                    objDistributorEmailAddress.Distributor = distributor;
                                    objDistributorEmailAddress.EmailAddress = email.Trim();
                                }
                            }

                            this.ObjContext.SaveChanges();
                        }

                        ts.Complete();
                    }
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while saving the Coordinator Email Address and Distributor Email Address", ex);
                }
            }

            this.PopulateDataGrid();
        }

        protected void btnDownloadBackOrder_Click(object sender, EventArgs e)
        {
            int distributor = int.Parse(((System.Web.UI.WebControls.WebControl)(sender)).Attributes["did"].ToString());

            DateTime WeekendDate = DateTime.Parse(((System.Web.UI.WebControls.WebControl)(sender)).Attributes["wdate"].ToString());

            if (distributor > 0 && WeekendDate != null)
            {
                string pdfFilePath = Common.GenerateOdsPdf.GenerateBackOrder(WeekendDate, distributor);

                this.DownloadPDFFile(pdfFilePath);
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

            //lblPopupHeaderText.Text = "New Age Group";
            ViewState["IsPageValied"] = true;
            Session["BackOrderDetails"] = null;

            this.PopulateDataGrid();

        }

        private void PopulateDataGrid()
        {
            {
                // Hide Controls
                this.dvEmptyContent.Visible = false;
                this.dvDataContent.Visible = false;
                this.dvNoSearchResult.Visible = false;

                // get the friday of the week
                var daysTillfriday = (int)DayOfWeek.Friday - (int)DateTime.Today.DayOfWeek;
                var friday = DateTime.Today.AddDays(daysTillfriday);

                // Search text
                string searchText = this.txtSearch.Text.ToLower().Trim();

                // Populate Items
                ReturnBackOrdersViewBO objReturnBackOrdersView = new ReturnBackOrdersViewBO();

                List<ReturnBackOrdersViewBO> lstReturnBackOrdersView = WeeklyProductionCapacityBO.GetBackOrderDetails(friday);
                if ((searchText != string.Empty) && (searchText != "search"))
                {
                    lstReturnBackOrdersView = lstReturnBackOrdersView.Where(o => o.Distributor.Contains(searchText) ||
                                                                                o.Coordinator.Contains(searchText)).ToList();
                }
                /* else
                 {
                     lstReturnBackOrdersView = objReturnBackOrdersView.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList();
                 }*/

                if (lstReturnBackOrdersView.Count > 0)
                {
                    this.RadGridBackOrders.AllowPaging = (lstReturnBackOrdersView.Count > this.RadGridBackOrders.PageSize);
                    this.RadGridBackOrders.DataSource = lstReturnBackOrdersView;
                    this.RadGridBackOrders.DataBind();
                    Session["BackOrderDetails"] = lstReturnBackOrdersView;

                    this.dvDataContent.Visible = true;
                }
                else if ((searchText != string.Empty && searchText != "search"))
                {
                    this.lblSerchKey.Text = searchText + ((searchText != string.Empty) ? " - " : string.Empty);

                    this.dvDataContent.Visible = true;
                    this.dvNoSearchResult.Visible = true;
                }
                else
                {
                    this.dvEmptyContent.Visible = true;
                    //this.btnAddAgeGroup.Visible = false;
                }

                this.RadGridBackOrders.Visible = (lstReturnBackOrdersView.Count > 0);
            }
        }

        //private void ProcessForm(int agegroupId, bool isDelete)
        //{
        //    try
        //    {
        //        using (TransactionScope ts = new TransactionScope())
        //        {
        //            ReturnBackOrdersViewBO objReturnBackOrdersView = new ReturnBackOrdersViewBO(this.ObjContext);
        //            if (agegroupId > 0)
        //            {
        //                objReturnBackOrdersView.ID = agegroupId;
        //                objReturnBackOrdersView.GetObject();
        //                objReturnBackOrdersView.Name = this.txtAgeGroupName.Text;
        //                objReturnBackOrdersView.Description = this.txtDescription.Text;

        //                if (isDelete)
        //                {
        //                    objReturnBackOrdersView.Delete();
        //                }
        //            }
        //            else
        //            {
        //                objReturnBackOrdersView.Name = this.txtAgeGroupName.Text;
        //                objReturnBackOrdersView.Description = this.txtDescription.Text;
        //                objReturnBackOrdersView.Add();
        //            }

        //            this.ObjContext.SaveChanges();
        //            ts.Complete();
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        //throw ex;
        //    }
        //}

        private void ReBindGrid()
        {
            if (Session["BackOrderDetails"] != null)
            {
                RadGridBackOrders.DataSource = (List<ReturnBackOrdersViewBO>)Session["BackOrderDetails"];
                RadGridBackOrders.DataBind();
            }
        }

        #endregion
    }
}