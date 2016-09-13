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
using System.IO;
using System.Drawing;

namespace Indico
{
    public partial class ViewQuotes : IndicoPage
    {
        #region Fields

        private static string emailTemplate = string.Empty;

        #endregion

        #region Properties

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["PatternAccessoryExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "Quote";
                }
                return sort;
            }
            set
            {
                ViewState["PatternAccessoryExpression"] = value;
            }
        }

        protected static string QuoteEmailTemplate
        {
            get
            {
                if (string.IsNullOrEmpty(emailTemplate))
                {
                    StreamReader rdr = new StreamReader(HttpContext.Current.Server.MapPath("~/Templates/Quote.html"));
                    emailTemplate = rdr.ReadToEnd();
                    rdr.Close();
                    rdr = null;
                }
                return emailTemplate;
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

        //protected void dgQuotes_ItemDataBound(object sender, DataGridItemEventArgs e)
        //{
        //    DataGridItem item = e.Item;
        //    if (item.ItemIndex > -1 && item.DataItem is QuoteBO)
        //    {
        //        QuoteBO objQuote = (QuoteBO)item.DataItem;

        //        Literal lblDateQuoted = (Literal)item.FindControl("lblDateQuoted");
        //        lblDateQuoted.Text = objQuote.DateQuoted.ToString("dd MMMM yyyy");

        //        Literal lblQuoteExpiryDate = (Literal)item.FindControl("lblQuoteExpiryDate");
        //        lblQuoteExpiryDate.Text = objQuote.QuoteExpiryDate.ToString("dd MMMM yyyy");

        //        Literal lblJobName = (Literal)item.FindControl("lblJobName");
        //        lblJobName.Text = objQuote.JobName;

        //        Literal lblFrom = (Literal)item.FindControl("lblFrom");
        //        lblFrom.Text = objQuote.objCreator.GivenName + " " + objQuote.objCreator.FamilyName;

        //        Literal lblTo = (Literal)item.FindControl("lblTo");
        //        lblTo.Text = objQuote.ContactName;

        //        Literal lblPattern = (Literal)item.FindControl("lblPattern");
        //        lblPattern.Text = (objQuote.Pattern != null && objQuote.Pattern > 0) ? objQuote.objPattern.Number : string.Empty;

        //        Literal lblFabric = (Literal)item.FindControl("lblFabric");
        //        lblFabric.Text = (objQuote.Fabric != null && objQuote.Fabric > 0) ? objQuote.objFabric.Name : string.Empty;

        //        Literal lblStatus = (Literal)item.FindControl("lblStatus");
        //        lblStatus.Text = "<span class=\"label label-" + objQuote.objStatus.Name.ToLower().Replace(" ", string.Empty).Trim() + "\">" + objQuote.objStatus.Name + "</span>";

        //        LinkButton linkViewQuotes = (LinkButton)item.FindControl("linkViewQuotes");
        //        linkViewQuotes.Attributes.Add("qid", objQuote.ID.ToString());

        //        HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
        //        linkEdit.Attributes.Add("qid", objQuote.ID.ToString());
        //        linkEdit.NavigateUrl = "AddEditQuote.aspx?id=" + objQuote.ID.ToString();

        //        HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
        //        linkDelete.Attributes.Add("qid", objQuote.ID.ToString());

        //        LinkButton lbResendMail = (LinkButton)item.FindControl("lbResendMail");
        //        lbResendMail.Attributes.Add("qid", objQuote.ID.ToString());
        //        lbResendMail.Visible = (objQuote.Status == 1) ? true : false;

        //    }
        //}

        protected void RadGridQuotes_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridQuotes_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridQuotes_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if (item.ItemIndex > -1 && item.DataItem is QuotesDetailsViewBO)
                {
                    QuotesDetailsViewBO objUserDetails = (QuotesDetailsViewBO)item.DataItem;

                    Literal lblStatus = (Literal)item.FindControl("lblStatus");
                    lblStatus.Text = "<span class=\"label label-" + objUserDetails.Status.ToLower().Replace(" ", string.Empty).Trim() + "\">" + objUserDetails.Status + "</span>";

                    LinkButton linkViewQuotes = (LinkButton)item.FindControl("linkViewQuotes");
                    linkViewQuotes.Attributes.Add("qid", objUserDetails.Quote.ToString());

                    HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
                    linkEdit.Attributes.Add("qid", objUserDetails.Quote.ToString());
                    linkEdit.NavigateUrl = "AddEditQuote.aspx?id=" + objUserDetails.Quote.ToString();

                    HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                    linkDelete.Attributes.Add("qid", objUserDetails.Quote.ToString());

                    LinkButton lbResendMail = (LinkButton)item.FindControl("lbResendMail");
                    lbResendMail.Attributes.Add("qid", objUserDetails.Quote.ToString());
                    lbResendMail.Visible = (objUserDetails.Status == "In Progress") ? true : false;
                }
            }
        }

        protected void RadGridQuotes_GroupsChanging(object sender, GridGroupsChangingEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridQuotes_SortCommand(object sender, GridSortCommandEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridQuotes_ItemCommand(object sender, GridCommandEventArgs e)
        {
            //if (e.CommandName == RadGrid.FilterCommandName)
            //{
            this.ReBindGrid();
            //}
        }

        protected void HeaderContextMenu_ItemCLick(object sender, RadMenuEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            ViewState["populateViewQuote"] = false;
            this.PopulateDataGrid();
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int quoteid = int.Parse(this.hdnSelectedPatternAccessoryID.Value.Trim());

            if (quoteid > 0)
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    QuoteBO objQuote = new QuoteBO(this.ObjContext);
                    objQuote.ID = quoteid;
                    objQuote.GetObject();

                    List<QuoteDetailBO> lstQuoteDetails = objQuote.QuoteDetailsWhereThisIsQuote;

                    if (lstQuoteDetails.Count > 0)
                    {
                        foreach (QuoteDetailBO qd in lstQuoteDetails)
                        {
                            QuoteDetailBO objQuoteDetail = new QuoteDetailBO(this.ObjContext);
                            objQuoteDetail.ID = qd.ID;
                            objQuoteDetail.GetObject();

                            objQuoteDetail.Delete();
                        }

                        this.ObjContext.SaveChanges();
                    }

                    objQuote.Delete();

                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }
            }

            this.PopulateDataGrid();
        }

        //protected void dgQuotes_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        //{
        //    // Set page index
        //    this.dgQuotes.CurrentPageIndex = e.NewPageIndex;

        //    this.PopulateDataGrid();
        //}

        //protected void dgQuotes_SortCommand(object source, DataGridSortCommandEventArgs e)
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

        //    foreach (DataGridColumn col in this.dgQuotes.Columns)
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

        protected void linkViewQuotes_OnClick(object sender, EventArgs e)
        {
            //if (this.IsNotRefresh) TODO NNM
            //{
            //    int QuoteID = int.Parse(((System.Web.UI.WebControls.WebControl)(sender)).Attributes["qid"]);

            //    QuoteBO objQuote = new QuoteBO();
            //    objQuote.ID = QuoteID;
            //    objQuote.GetObject();


            //    this.lblPopupHeaderText.Text = "View Quote Details";
            //    string priceterm = (objQuote.PriceTerm != null && objQuote.PriceTerm > 0) ? objQuote.objPriceTerm.Name : string.Empty;

            //    this.lblQuotedDate.Text = objQuote.DateQuoted.ToLongDateString();
            //    this.lblExpiryDate.Text = objQuote.QuoteExpiryDate.ToLongDateString();
            //    this.lblDiliveryDate.Text = (objQuote.DeliveryDate != null) ? Convert.ToDateTime(objQuote.DeliveryDate.ToString()).ToLongDateString() : string.Empty;
            //    this.lblJobName.Text = objQuote.JobName;
            //    this.lblContactName.Text = objQuote.ContactName;
            //    this.liItem.Visible = (objQuote.Pattern != null && objQuote.Pattern > 0) ? true : false;
            //    this.liFabric.Visible = (objQuote.Fabric != null && objQuote.Fabric > 0) ? true : false;
            //    this.lblPattern.Text = (objQuote.Pattern != null && objQuote.Pattern > 0) ? objQuote.objPattern.Number + " - " + objQuote.objPattern.NickName : string.Empty;
            //    this.lblFabricCode.Text = (objQuote.Fabric != null && objQuote.Fabric > 0) ? objQuote.objFabric.Code.ToString() + " - " + objQuote.objFabric.NickName : string.Empty;
            //    this.liquantity.Visible = (objQuote.Qty > 0) ? true : false;
            //    this.lblQuantity.Text = (objQuote.Qty > 0) ? objQuote.Qty.ToString() : string.Empty;
            //    this.liPrice.Visible = ((objQuote.IndimanPrice != null && objQuote.IndimanPrice > 0) || (objQuote.PriceTerm != null && objQuote.PriceTerm > 0)) ? true : false;
            //    this.lblIndimanPrice.Text = Convert.ToDecimal(objQuote.IndimanPrice).ToString("0.00") + " " + priceterm;
            //    this.lblStatus.Text = (objQuote.Status > 0) ? objQuote.objStatus.Name : string.Empty;
            //    this.liNotes.Visible = (string.IsNullOrEmpty(objQuote.Notes)) ? false : true;
            //    this.lblNotes.Text = (string.IsNullOrEmpty(objQuote.Notes)) ? string.Empty : objQuote.Notes;
            //    this.liDistributor.Visible = (objQuote.Distributor != null && objQuote.Distributor > 0) ? true : false;
            //    this.lblDistributor.Text = (objQuote.Distributor != null && objQuote.Distributor > 0) ? objQuote.objDistributor.Name : string.Empty;

            //    ViewState["populateViewQuote"] = true;
            //}
        }

        protected void ddlSortBy_SelectedIndexChanged(object sender, EventArgs e)
        {
            ViewState["populateViewQuote"] = false;
            PopulateDataGrid();
        }

        protected void lbResendMail_OnClick(object sender, EventArgs e)
        {
            int QuoteID = int.Parse(((System.Web.UI.WebControls.WebControl)(sender)).Attributes["qid"]);

            if (QuoteID > 0)
            {
                QuoteBO objQuote = new QuoteBO();
                objQuote.ID = QuoteID;
                objQuote.GetObject();
                try
                {
                    string mailcc = string.Empty;
                    List<QuoteChangeEmailListBO> lstQuoteChangeEmailListCC = (new QuoteChangeEmailListBO()).SearchObjects().Where(o => o.IsCC == true).ToList();

                    foreach (QuoteChangeEmailListBO ccList in lstQuoteChangeEmailListCC)
                    {
                        UserBO objUser = new UserBO();
                        objUser.ID = (int)ccList.User;
                        objUser.GetObject();
                        mailcc += objUser.EmailAddress + ",";
                    }

                    //mailcc = "nisithamasakorala@hotmail.com";

                    //string emailContent = CheckQuotes.CreateQuoteDetailBody(objQuote);
                    //string emailTemp = QuoteEmailTemplate;
                    //string emailTemp = CheckQuotes.CreateQuoteDetailBody(objQuote);

                    string emailTemp = GenerateOdsPdf.CreateQuoteDetail(objQuote);
                    string emailLogoPath = string.Empty;

                    string[] attachment = { GenerateOdsPdf.CreateQuoteDetailAttachments(QuoteID) };

                    /*if (!string.IsNullOrEmpty(objQuote.JobName))
                    {
                        emailContent += " <tr>" +
                                          "<td width=\"200\" style=\"border-left:0px; border-top:0; font-size:11px; font-family: Arial; background:#CAE8EA no-repeat; color:#000000; border-left:0px solid #ffffff; border-right:0px solid #ffffff; border-bottom:0px solid #ffffff; border-top:0px solid #ffffff;  text-align:left;  background:#fff \" scope=\"row\">" + "Job Name" + "</td>" +
                                          "<td width=\"480\" style=\"border-right:0px solid #ffffff;font-size:11px; font-family: Arial; border-bottom:0px solid #ffffff; border-top:0px solid #ffffff;  background:#fff;  color:#000000\">" + objQuote.JobName + "</td>" +
                                          "</tr>";
                    }

                    if (objQuote.Pattern != null && objQuote.Pattern > 0)
                    {
                        emailContent += " <tr>" +
                                          "<td width=\"200\" style=\"border-left:0px; border-top:0; font-size:11px; font-family: Arial; background:#CAE8EA no-repeat; color:#000000; border-left:0px solid #ffffff; border-right:0px solid #ffffff; border-bottom:0px solid #ffffff; border-top:0px solid #ffffff;  text-align:left;  background:#fff \" scope=\"row\">" + "Item" + "</td>" +
                                          "<td width=\"480\" style=\"border-right:0px solid #ffffff; font-size:11px; font-family: Arial; border-bottom:0px solid #ffffff; border-top:0px solid #ffffff;  background:#fff;  color:#000000\">" + objQuote.objPattern.Number + " " + objQuote.objPattern.NickName + "</td>" +
                                          "</tr>";
                    }

                    if ((objQuote.IndimanPrice != null && objQuote.IndimanPrice > 0))
                    {
                        string priceterm = (objQuote.PriceTerm != null && objQuote.PriceTerm > 0) ? objQuote.objPriceTerm.Name : string.Empty;
                        string currency = (objQuote.Currency != null && objQuote.Currency > 0) ? objQuote.objCurrency.Code : string.Empty;
                        emailContent += " <tr>" +
                                         "<td width=\"200\" style=\"border-left:0px; border-top:0; font-size:11px; font-family: Arial; background:#CAE8EA no-repeat; color:#000000; border-left:0px solid #ffffff; border-right:0px solid #ffffff; border-bottom:0px solid #ffffff; border-top:0px solid #ffffff;  text-align:left;  background:#fff \" scope=\"row\">" + "Price" + "</td>" +
                                         "<td width=\"480\" style=\"border-right:0px solid #ffffff; font-size:11px; font-family: Arial; border-bottom:0px solid #ffffff; border-top:0px solid #ffffff;  background:#fff;  color:#000000\">" + currency + " " + Convert.ToDecimal(objQuote.IndimanPrice).ToString("0.00") + " " + priceterm + "</td>" +
                                         "</tr>";
                    }

                    if (objQuote.Qty != null)
                    {
                        emailContent += " <tr>" +
                                          "<td width=\"200\" style=\"border-left:1px; border-top:0; font-size:11px; font-family: Arial; background:#CAE8EA no-repeat; color:#000000; border-left:0px solid #ffffff; border-right:0px solid #ffffff; border-bottom:0px solid #ffffff; border-top:0px solid #ffffff;  text-align:left;  background:#fff \" scope=\"row\">" + "Indicated Quantity" + "</td>" +
                                         "<td width=\"480\" style=\"border-right:0px solid #ffffff; font-size:11px; font-family: Arial; border-bottom:0px solid #ffffff; border-top:0px solid #ffffff;  background:#fff;  color:#000000\">" + objQuote.Qty.ToString() + "</td>" +
                                         "</tr>";
                    }

                    if (objQuote.DeliveryDate != null)
                    {
                        emailContent += " <tr>" +
                                         "<td width=\"200\" style=\"border-left:0px; border-top:0; font-size:11px; font-family: Arial; background:#CAE8EA no-repeat; color:#000000; border-left:0px solid #ffffff; border-right:0px solid #ffffff; border-bottom:0px solid #ffffff; border-top:0px solid #ffffff;  text-align:left;  background:#fff \" scope=\"row\">" + "Approx. despatch date" + "</td>" +
                                         "<td width=\"480\" style=\"border-right:0px solid #ffffff; font-size:11px; font-family: Arial; border-bottom:0px solid #ffffff; border-top:0px solid #ffffff;  background:#fff;  color:#000000\">" + Convert.ToDateTime(objQuote.DeliveryDate).ToString("dd MMMM yyyy") + "</td>" +
                                         "</tr>";
                    }

                    if (objQuote.QuoteExpiryDate != null)
                    {
                        emailContent += " <tr>" +
                                        " <td width=\"200\" style=\"border-left:0px; border-top:0; font-size:11px; font-family: Arial; background:#CAE8EA no-repeat; color:#000000; border-left:0px solid #ffffff; border-right:0px solid #ffffff; border-bottom:0px solid #ffffff; border-top:0px solid #ffffff;  text-align:left;  background:#fff \" scope=\"row\">" + "Expires On" + "</td>" +
                                        " <td width=\"480\" style=\"border-right:0px solid #ffffff; font-size:11px; font-family: Arial; border-bottom:0px solid #ffffff; border-top:0px solid #ffffff;  background:#fff;  color:#000000\">" + Convert.ToDateTime(objQuote.QuoteExpiryDate).ToString("dd MMMM yyyy") + "</td>" +
                                        " </tr>";
                    }

                    if (!string.IsNullOrEmpty(objQuote.Notes))
                    {
                        emailContent += " <tr>" +
                                         "<td width=\"200\" style=\"border-left:1px; border-top:0; font-size:11px; font-family: Arial; background:#CAE8EA no-repeat; color:#000000; border-left:0px solid #ffffff; border-right:0px solid #ffffff; border-bottom:0px solid #ffffff; border-top:0px solid #ffffff;  text-align:left;  background:#fff \" scope=\"row\">" + "Notes" + "</td>" +
                                         "<td width=\"480\" style=\"border-right:0px solid #ffffff; font-size:11px; font-family: Arial; border-bottom:0px solid #ffffff; border-top:0px solid #ffffff;  background:#fff;  color:#000000\">" + objQuote.Notes + "</td>" +
                                         "</tr>";
                    }

                    if (objQuote.Distributor != null && objQuote.Distributor > 0)
                    {
                        emailContent += " <tr>" +
                                         "<td width=\"200\" style=\"border-left:1px; border-top:0; font-size:11px; font-family: Arial; background:#CAE8EA no-repeat; color:#000000; border-left:0px solid #ffffff; border-right:0px solid #ffffff; border-bottom:0px solid #C1DAD7; border-top:0px solid #ffffff;  text-align:left;  background:#fff \" scope=\"row\">" + "Distributor" + "</td>" +
                                         "<td width=\"480\" style=\"border-right:0px solid #ffffff; font-size:11px; font-family: Arial; border-bottom:0px solid #ffffff; border-top:0px solid #ffffff;  background:#fff;  color:#000000\">" + objQuote.objDistributor.Name + "</td>" +
                                         "</tr>";
                    }


                    emailTemp = emailTemp.Replace("<$tabledata$>", emailContent);
                    emailTemp = emailTemp.Replace("<$contactname$>", objQuote.ContactName);
                    string designation = (!string.IsNullOrEmpty(LoggedUser.Designation)) ? (" | " + LoggedUser.Designation) : string.Empty;
                    emailTemp = emailTemp.Replace("<$name$>", LoggedUser.GivenName + " " + LoggedUser.FamilyName + "" + designation);
                    emailTemp = emailTemp.Replace(" <$email$>", LoggedUser.EmailAddress);
                    emailTemp = emailTemp.Replace(" <$phone$>", LoggedUser.OfficeTelephoneNumber);
                    emailTemp = emailTemp.Replace("<$Mobile$>", (LoggedUser.MobileTelephoneNumber != null && !string.IsNullOrEmpty(LoggedUser.MobileTelephoneNumber)) ? LoggedUser.MobileTelephoneNumber : string.Empty);
                    emailTemp = emailTemp.Replace("<$fax$>", LoggedUser.objCompany.Fax);

                    EmailLogoBO objEmailLogo = new EmailLogoBO().SearchObjects().SingleOrDefault();

                    if (objEmailLogo != null)
                    {
                        emailLogoPath = IndicoConfiguration.AppConfiguration.DataFolderName + "/EmailLogos/" + objEmailLogo.EmailLogoPath;

                        if (!File.Exists(Server.MapPath(emailLogoPath)))
                        {
                            emailLogoPath = IndicoConfiguration.AppConfiguration.DataFolderName + "/EmailLogos/logo_login.png";
                        }
                    }
                    else
                    {
                        emailLogoPath = IndicoConfiguration.AppConfiguration.DataFolderName + "/EmailLogos/logo_login.png";
                    }

                    System.Drawing.Image emailImage = System.Drawing.Image.FromFile(Server.MapPath(emailLogoPath));
                    SizeF emailLogo = emailImage.PhysicalDimension;
                    emailImage.Dispose();

                    List<float> lstVLImageDimensions = (new ImageProcess()).GetResizedImageDimensionForHeight(Convert.ToInt32(Math.Abs(emailLogo.Width)), Convert.ToInt32(Math.Abs(emailLogo.Height)), 110);

                    emailLogoPath = "http://" + IndicoConfiguration.AppConfiguration.SiteHostAddress + "/" + emailLogoPath;
                    emailTemp = emailTemp.Replace("<$logoimage$>", "<img src=\"" + emailLogoPath + "\" height=\"" + lstVLImageDimensions[0].ToString() + "\" width=\"" + lstVLImageDimensions[1].ToString() + "\"/>");

                    */

                    if (!string.IsNullOrEmpty(mailcc))
                    {
                        //GenerateOdsPdf.GenerateQuoteDetail(QuoteID); 
                        mailcc += LoggedUser.EmailAddress + ",";
                        IndicoEmail.SendMail(LoggedUser.GivenName + " " + LoggedUser.FamilyName, LoggedUser.EmailAddress, objQuote.ContactName, objQuote.ClientEmail, mailcc, "Quote: QT" + " - " + QuoteID, null, attachment, false, emailTemp);
                    }
                }
                catch (Exception ex)
                {

                    IndicoLogging.log.Error("Errour occured while send resend quote mail  from ViewQuotes.aspx page", ex);
                }
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

            //ViewState["IsPageValied"] = true;

            //populate sort by Status

            this.ddlSortStatus.Items.Clear();
            this.ddlSortStatus.Items.Add(new ListItem("All", "0"));
            List<QuoteStatusBO> lstQuoteStatus = (from o in (new QuoteStatusBO()).SearchObjects() select o).ToList();
            foreach (QuoteStatusBO status in lstQuoteStatus)
            {
                this.ddlSortStatus.Items.Add(new ListItem(status.Name, status.ID.ToString()));
            }

            Session["QuoteDetailsView"] = null;

            this.PopulateDataGrid();

        }

        private void PopulateDataGrid()
        {
            // Hide Controls
            this.dvEmptyContent.Visible = false;
            this.dvDataContent.Visible = false;
            this.dvNoSearchResult.Visible = false;

            // Search text
            string searchText = this.txtSearch.Text.ToLower().Trim();

            // Populate Items
            QuotesDetailsViewBO objQuote = new QuotesDetailsViewBO();
            objQuote.CreatorID = this.LoggedUser.ID;

            List<QuotesDetailsViewBO> lstQuote = new List<QuotesDetailsViewBO>();

            if ((searchText != string.Empty) && (searchText != "search"))
            {
                lstQuote = (from o in objQuote.SearchObjects().AsQueryable().OrderByDescending(o => o.Quote).ToList()
                            where (o.Quote.ToString().Trim().Contains(searchText) ||
                                   o.ClietEMail.ToLower().Trim().Contains(searchText) ||
                                   o.JobName.ToLower().Trim().Contains(searchText))
                            select o).ToList();
            }
            else
            {
                lstQuote = objQuote.SearchObjects().AsQueryable().OrderByDescending(o => o.Quote).ToList();
            }

            if (this.ddlSortStatus.SelectedIndex != 0)
            {
                lstQuote = lstQuote.Where(o => o.Status == this.ddlSortStatus.SelectedItem.Text).ToList();
            }

            if (lstQuote.Count > 0)
            {
                this.RadGridQuotes.AllowPaging = (lstQuote.Count > this.RadGridQuotes.PageSize);
                this.RadGridQuotes.DataSource = lstQuote;
                this.RadGridQuotes.DataBind();
                Session["QuoteDetailsView"] = lstQuote;

                this.dvDataContent.Visible = true;
            }
            else if ((searchText != string.Empty && searchText != "search") || (this.ddlSortStatus.SelectedValue != "0" && lstQuote.Count == 0))
            {
                this.lblSerchKey.Text = searchText + ((searchText != string.Empty) ? " - " : string.Empty);

                this.dvDataContent.Visible = true;
                this.dvNoSearchResult.Visible = true;
            }
            else
            {
                this.dvEmptyContent.Visible = true;
                this.RadGridQuotes.Visible = false;
                this.btnAddQuote.Visible = false;
            }

            this.RadGridQuotes.Visible = (lstQuote.Count > 0);
        }

        private void ReBindGrid()
        {
            if (Session["QuoteDetailsView"] != null)
            {
                RadGridQuotes.DataSource = (List<QuotesDetailsViewBO>)Session["QuoteDetailsView"];
                RadGridQuotes.DataBind();
            }
        }

        #endregion

    }
}