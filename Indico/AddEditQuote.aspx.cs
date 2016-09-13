using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Transactions;
using System.IO;

using Indico.BusinessObjects;
using Indico.Common;
using System.Drawing;
using System.Web.UI.HtmlControls;

namespace Indico
{
    public partial class AddEditQuote : IndicoPage
    {
        #region Fields

        private int urlQueryID = -1;
        private string sort = string.Empty;
        static string emailTemplate = string.Empty;


        #endregion

        #region Properties

        protected int QueryID
        {
            get
            {
                if (urlQueryID > -1)
                    return urlQueryID;

                urlQueryID = 0;
                if (Request.QueryString["id"] != null)
                {
                    urlQueryID = Convert.ToInt32(Request.QueryString["id"].ToString());
                }
                return urlQueryID;
            }
        }

        private string SortExpression
        {
            get
            {
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "ID";
                }
                return sort;
            }
            set
            {
                sort = value;
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

        private int QuoteID
        {
            get
            {
                int id = (ViewState["QuoteID"] == null) ? 0 : int.Parse(ViewState["QuoteID"].ToString());
                return id;
            }
            set
            {
                ViewState["QuoteID"] = value;
            }
        }

        private int QuoteDetailID
        {
            get
            {
                int id = (ViewState["QuoteDetailID"] == null) ? 0 : int.Parse(ViewState["QuoteDetailID"].ToString());
                return id;
            }
            set
            {
                ViewState["QuoteDetailID"] = value;
            }
        }

        #endregion

        #region Constructors

        #endregion

        #region Event

        protected override void OnPreRender(EventArgs e)
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

        protected void btnSaveChanges_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                this.ProcessForm(false);

                Response.Redirect("/ViewQuotes.aspx");
            }
        }

        protected void cvNotes_OnServerValidate(object sender, ServerValidateEventArgs e)
        {
            if (!string.IsNullOrEmpty(this.txtNotes.Text))
            {
                e.IsValid = (this.txtNotes.Text.Length > 255) ? false : true;
            }
        }

        protected void cvQuoteExpiryDate_OnServerValidate(object sender, ServerValidateEventArgs e)
        {
            DateTime tempDateTime;
            if (!string.IsNullOrEmpty(this.txtQuoteExpiryDate.Text))
            {
                if (DateTime.TryParse(this.txtQuoteExpiryDate.Text, out tempDateTime))
                {
                    e.IsValid = true;
                }
                else
                {
                    e.IsValid = false;
                }
            }
        }

        protected void cvDeliveryDate_OnServerValidate(object sender, ServerValidateEventArgs e)
        {
            DateTime tempDateTime;
            if (!string.IsNullOrEmpty(this.txtDeliveryDate.Text))
            {
                if (DateTime.TryParse(this.txtDeliveryDate.Text, out tempDateTime))
                {
                    e.IsValid = true;
                }
                else
                {
                    e.IsValid = false;
                }
            }
        }

        protected void btnSaveChangesSendMail_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                this.ProcessForm(false);

                if (this.QueryID > 0)
                {
                    this.SendMail(QuoteID);
                }
                Response.Redirect("/ViewQuotes.aspx");
            }
        }

        protected void btnCCEmailAddress_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                int isUsed = 0;

                // populate CC Exist Users
                List<UserBO> lstUsers = (new UserBO()).SearchObjects().Where(o => o.Status == 1 && o.Company == 4).ToList();
                isUsed = 0;
                this.lstBoxCcExistUsers.Items.Clear();
                this.lstBoxCccNewUsers.Items.Clear();
                List<QuoteChangeEmailListBO> lstQuoteChangeCCEmailList = (new QuoteChangeEmailListBO()).SearchObjects().Where(o => o.IsCC == true).ToList();


                if (lstQuoteChangeCCEmailList.Count > 0)
                {
                    foreach (UserBO userCc in lstUsers)
                    {
                        this.lstBoxCcExistUsers.Items.Add(new ListItem(userCc.GivenName + " " + userCc.FamilyName + " - " + userCc.EmailAddress, userCc.ID.ToString()));
                    }

                    foreach (QuoteChangeEmailListBO pcelcc in lstQuoteChangeCCEmailList)
                    {
                        this.lstBoxCccNewUsers.Items.Add(new ListItem(pcelcc.objUser.GivenName + " " + pcelcc.objUser.FamilyName + " - " + pcelcc.objUser.EmailAddress, pcelcc.User.ToString()));

                        if (pcelcc.User != isUsed)
                        {
                            this.lstBoxCcExistUsers.Items.FindByValue(pcelcc.User.ToString()).Selected = true;
                            this.lstBoxCcExistUsers.Items.Remove(this.lstBoxCcExistUsers.SelectedItem);
                            isUsed = (int)pcelcc.User;
                        }
                    }
                }
                else
                {
                    foreach (UserBO userCc in lstUsers)
                    {
                        this.lstBoxCcExistUsers.Items.Add(new ListItem(userCc.GivenName + " " + userCc.FamilyName + " - " + userCc.EmailAddress, userCc.ID.ToString()));
                    }
                }
                ViewState["PopulateEmailAddress"] = true;
                Session["IsRefresh"] = Server.UrlEncode(System.DateTime.Now.ToString());
            }
            else
            {
                ViewState["PopulateEmailAddress"] = false;
            }

        }

        protected void btnSaveEmailAddresses_OnClick(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                try
                {
                    if (this.hdnEmailAddressesCC.Value != string.Empty)
                    {
                        List<QuoteChangeEmailListBO> lstQuoteChangeEmailListCC = (new QuoteChangeEmailListBO()).SearchObjects().Where(o => o.IsCC == true).ToList();

                        if (this.hdnEmailAddressesCC.Value != string.Empty)
                        {
                            using (TransactionScope ts = new TransactionScope())
                            {
                                if (lstQuoteChangeEmailListCC.Count > 0)
                                {
                                    foreach (QuoteChangeEmailListBO cclist in lstQuoteChangeEmailListCC)
                                    {
                                        QuoteChangeEmailListBO objPriceChangeEmailList = new QuoteChangeEmailListBO(this.ObjContext);
                                        objPriceChangeEmailList.ID = cclist.ID;
                                        objPriceChangeEmailList.GetObject();

                                        objPriceChangeEmailList.Delete();

                                        this.ObjContext.SaveChanges();

                                    }
                                    ts.Complete();
                                }
                            }

                            using (TransactionScope ts = new TransactionScope())
                            {
                                foreach (string value in this.hdnEmailAddressesCC.Value.Split(','))
                                {
                                    if (value != string.Empty)
                                    {
                                        QuoteChangeEmailListBO objPriceChangeEmailList = new QuoteChangeEmailListBO(this.ObjContext);
                                        objPriceChangeEmailList.User = int.Parse(value);
                                        objPriceChangeEmailList.IsCC = true;

                                        this.ObjContext.SaveChanges();
                                    }
                                }
                                ts.Complete();
                            }
                        }
                    }

                }
                catch (Exception ex)
                {

                    IndicoLogging.log.Error("Error occured while saving PriceChangeEmailList", ex);
                }
            }

            ViewState["PopulateEmailAddress"] = false;
        }

        protected void btnQuoteDetail_ServerClick(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                this.ProcessForm(true, this.QuoteDetailID);

                this.PopulateQuoteDetail(QuoteID);

                //this.PopulatePatterns(this.QuoteID);

                //this.PopulateFabrics(this.QuoteID);
                //this.ddlPattern.Items.FindByValue(this.ddlPattern.SelectedValue).Selected = false;
                //this.ddlFabric.Items.FindByValue(this.ddlFabric.SelectedValue).Selected = false;
                //this.ddlPriceTerm.Items.FindByValue(this.ddlPriceTerm.SelectedValue).Selected = false;
                //this.ddlDesignType.Items.FindByValue(this.ddlDesignType.SelectedValue).Selected = false;
                // this.ddlUnits.Items.FindByValue(this.ddlUnits.SelectedValue).Selected = false;
                // this.ddlVisualLayout.Items.FindByValue(this.ddlVisualLayout.SelectedValue).Selected = false;

                this.ddlPattern.SelectedValue = "0";
                this.ddlFabric.SelectedValue = "0";

                this.ddlPriceTerm.SelectedValue = "0";

                this.ddlDesignType.SelectedValue = "0";

                this.ddlUnits.SelectedValue = "0";
                this.chkIsGST.Checked = false;
                this.txtGST.Text = string.Empty;
                this.txtIndimanPrice.Text = string.Empty;
                this.txtDesignFee.Text = string.Empty;
                this.txtQty.Text = string.Empty;
                this.txtNotes.Text = string.Empty;
                this.txtDeliveryDate.Text = string.Empty;
                               // this.ddlVisualLayout.SelectedValue = "0";
            }

            this.collapse2.Attributes.Add("class", "accordion-body collapse in");
        }

        protected void dgQuoteDetails_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            var item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is QuoteDetailBO)
            {
                QuoteDetailBO objQuoteDetail = (QuoteDetailBO)item.DataItem;

                Literal litDeliveryDate = (Literal)item.FindControl("litDeliveryDate");
                litDeliveryDate.Text = (objQuoteDetail.DelivaryDate != null) ? Convert.ToDateTime(objQuoteDetail.DelivaryDate.ToString()).ToString("dd MMMM yyyy") : string.Empty;

                Literal litPattern = (Literal)item.FindControl("litPattern");
                litPattern.Text = objQuoteDetail.objPattern.Number + " " + objQuoteDetail.objPattern.NickName;

                Literal litFabic = (Literal)item.FindControl("litFabic");
                litFabic.Text = objQuoteDetail.objFabric.Code + "  " + objQuoteDetail.objFabric.NickName;

                Literal litVisualLayout = (Literal)item.FindControl("litVisualLayout");
                litVisualLayout.Text = (objQuoteDetail.VisualLayout != null && objQuoteDetail.VisualLayout > 0) ? objQuoteDetail.objVisualLayout.NamePrefix : string.Empty;

                Literal litDesignType = (Literal)item.FindControl("litDesignType");
                litDesignType.Text = (objQuoteDetail.DesignType != null && objQuoteDetail.DesignType > 0) ? objQuoteDetail.objDesignType.Name : string.Empty;

                Literal litPriceTerm = (Literal)item.FindControl("litPriceTerm");
                litPriceTerm.Text = (objQuoteDetail.PriceTerm != null && objQuoteDetail.PriceTerm > 0) ? objQuoteDetail.objPriceTerm.Name : string.Empty;

                Literal litQty = (Literal)item.FindControl("litQty");
                litQty.Text = objQuoteDetail.Qty.ToString();

                Literal litIndimanPrice = (Literal)item.FindControl("litIndimanPrice");
                litIndimanPrice.Text = (objQuoteDetail.IndimanPrice != null) ? Convert.ToDecimal(objQuoteDetail.IndimanPrice.ToString()).ToString("0.00") : "0.00";

                CheckBox chkIsGST = (CheckBox)item.FindControl("chkIsGST");
                chkIsGST.Checked = (bool)objQuoteDetail.IsGST;

                Literal litGST = (Literal)item.FindControl("litGST");
                litGST.Text = (objQuoteDetail.GST != null) ? Convert.ToDecimal(objQuoteDetail.GST.ToString()).ToString("0.00") : "0.00";

                Literal litTotal = (Literal)item.FindControl("litTotal");

                decimal indimanprice = (objQuoteDetail.IndimanPrice != null) ? (decimal)objQuoteDetail.IndimanPrice : 0;
                decimal gst = (objQuoteDetail.GST != null) ? (decimal)objQuoteDetail.GST : 0;

                decimal total = ((indimanprice + gst) * objQuoteDetail.Qty);

                litTotal.Text = String.Format("{0:n}", total); // totoal.ToString("0.00");

                HtmlAnchor linkEdit = (HtmlAnchor)item.FindControl("linkEdit");
                linkEdit.Attributes.Add("qid", objQuoteDetail.ID.ToString());
            }
        }

        protected void linkEdit_ServerClick(object sender, EventArgs e)
        {
            try
            {
                this.btnQuoteDetail.InnerText = "Update Quote Detail";

                QuoteDetailBO objQuoteDetail = new QuoteDetailBO();
                objQuoteDetail.ID = int.Parse(((HtmlAnchor)sender).Attributes["qid"].ToString());
                objQuoteDetail.GetObject();

                this.QuoteDetailID = int.Parse(((HtmlAnchor)sender).Attributes["qid"].ToString());

                //this.PopulatePatterns(objQuoteDetail.Quote, objQuoteDetail.Pattern);

                //this.PopulateFabrics(objQuoteDetail.Quote, objQuoteDetail.Fabric);

               // this.PopulateVisualLayout(objQuoteDetail.Pattern, objQuoteDetail.Fabric);

                this.ddlPattern.SelectedIndex = this.ddlFabric.SelectedIndex = this.ddlPriceTerm.SelectedIndex =
                   this.ddlDesignType.SelectedIndex = this.ddlUnits.SelectedIndex = -1; //this.ddlVisualLayout.SelectedIndex

                this.ddlPattern.Items.FindByValue(objQuoteDetail.Pattern.ToString()).Selected = true;
                this.ddlFabric.Items.FindByValue(objQuoteDetail.Fabric.ToString()).Selected = true;
                //this.ddlPriceTerm.Items.FindByValue("0").Selected = false;
                this.ddlPriceTerm.Items.FindByValue((objQuoteDetail.PriceTerm != null && objQuoteDetail.PriceTerm > 0) ? objQuoteDetail.PriceTerm.ToString() : "0").Selected = true;
                //this.ddlDesignType.Items.FindByValue("0").Selected = false;
                this.ddlDesignType.Items.FindByValue((objQuoteDetail.DesignType != null && objQuoteDetail.DesignType > 0) ? objQuoteDetail.DesignType.ToString() : "0").Selected = true;
                //this.ddlUnits.Items.FindByValue("0").Selected = false;
                this.ddlUnits.Items.FindByValue((objQuoteDetail.Unit != null && objQuoteDetail.Unit > 0) ? objQuoteDetail.Unit.ToString() : "0").Selected = true;
                this.chkIsGST.Checked = (bool)objQuoteDetail.IsGST;
                this.txtGST.Text = (objQuoteDetail.GST != null) ? objQuoteDetail.GST.ToString() : string.Empty;
                this.txtIndimanPrice.Text = (objQuoteDetail.IndimanPrice != null) ? Convert.ToDecimal(objQuoteDetail.IndimanPrice.ToString()).ToString("0.00") : string.Empty;
                this.txtDesignFee.Text = (objQuoteDetail.DesignFee != null) ? Convert.ToDecimal(objQuoteDetail.DesignFee.ToString()).ToString("0.00") : string.Empty;
                this.txtQty.Text = Convert.ToDecimal(objQuoteDetail.Qty.ToString()).ToString();
                this.txtNotes.Text = objQuoteDetail.Notes;
                this.txtDeliveryDate.Text = (objQuoteDetail.DelivaryDate != null) ? Convert.ToDateTime(objQuoteDetail.DelivaryDate.ToString()).ToString("dd MMMM yyyy") : string.Empty;
                //this.ddlVisualLayout.Items.FindByValue("0").Selected = false;
                //this.ddlVisualLayout.Items.FindByValue((objQuoteDetail.VisualLayout != null && objQuoteDetail.VisualLayout > 0) ? objQuoteDetail.VisualLayout.ToString() : "0").Selected = true;
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while editing Quote Detail in AddEditQuote.aspx", ex);
            }

            this.collapse2.Attributes.Add("class", "accordion-body collapse in");
        }

        protected void ddlPattern_SelectedIndexChanged(object sender, EventArgs e)
        {
            //int id = int.Parse(this.ddlPattern.SelectedValue);

            //if (id > 0)
            //{
            //    if (!this.CheckExsistsPattenFabric(id, int.Parse(this.ddlFabric.SelectedValue), (this.QueryID > 0) ? this.QueryID : this.QuoteID))
            //    {
            //        this.PopulateVisualLayout(id, int.Parse(this.ddlFabric.SelectedValue));
            //    }
            //}

            this.collapse2.Attributes.Add("class", "accordion-body collapse in");
        }

        protected void ddlFabric_SelectedIndexChanged(object sender, EventArgs e)
        {
            int id = int.Parse(this.ddlFabric.SelectedValue);

            //if (id > 0)
            //{
            //    if (!this.CheckExsistsPattenFabric(int.Parse(this.ddlPattern.SelectedValue), id, (this.QueryID > 0) ? this.QueryID : this.QuoteID))
            //    {
            //        this.PopulateVisualLayout(int.Parse(this.ddlPattern.SelectedValue), id);
            //    }
            //}

            this.collapse2.Attributes.Add("class", "accordion-body collapse in");
        }

        # endregion

        #region Methods

        /// <summary>
        /// Populate the controls.
        /// </summary>
        private void PopulateControls()
        {
            ViewState["PopulateEmailAddress"] = false;
            this.litPatternError.Visible = false;

            //Header Text
            this.litHeaderText.Text = ((this.QueryID > 0) ? "Edit " : "New ") + this.ActivePage.Heading;

            //populate Button Save & SendMail
            //   this.btnSaveChangesSendMail.Visible = (this.QueryID > 0) ? true : false;

            // Populate Fabric Code
            this.PopulateFabrics();

            // Populate Pattern
            this.PopulatePatterns();

            //populate VisualLayout
            //this.PopulateVisualLayout();
            
            // Populate price term
            this.ddlPriceTerm.Items.Clear();
            this.ddlPriceTerm.Items.Add(new ListItem("Select Price Term", "0"));
            List<PriceTermBO> lstPriceTerms = (from o in (new PriceTermBO()).SearchObjects() select o).ToList();
            foreach (PriceTermBO priceTerm in lstPriceTerms)
            {
                this.ddlPriceTerm.Items.Add(new ListItem(priceTerm.Name, priceTerm.ID.ToString()));
            }

            //populate Status 
            this.ddlStatus.Items.Clear();
            this.ddlStatus.Items.Add(new ListItem("Select Status", "0"));
            List<QuoteStatusBO> lstQuoteStatus = (from o in (new QuoteStatusBO()).GetAllObject() select o).ToList();
            foreach (QuoteStatusBO status in lstQuoteStatus)
            {
                this.ddlStatus.Items.Add(new ListItem(status.Name, status.ID.ToString()));
            }
                       
            // populate Currency
            this.ddlCurrency.Items.Clear();
            this.ddlCurrency.Items.Add(new ListItem("Select Currency Type", "0"));
            List<CurrencyBO> lstCurrency = (from o in (new CurrencyBO()).GetAllObject() select o).ToList();
            foreach (CurrencyBO currency in lstCurrency)
            {
                this.ddlCurrency.Items.Add(new ListItem(currency.Name, currency.ID.ToString()));
            }
            
            //populate Distributor
            //this.ddlDistributor.Items.Clear();
            //this.ddlDistributor.Items.Add(new ListItem("Select Distributor", "0"));
            //List<CompanyBO> lstCompany = (new CompanyBO()).SearchObjects().Where(o => o.IsDistributor == true && o.IsActive == true).OrderBy(o => o.Name).ToList();
            //foreach (CompanyBO distributor in lstCompany)
            //{
            //    this.ddlDistributor.Items.Add(new ListItem(distributor.Name, distributor.ID.ToString()));
            //}

            //populate Design Type
            this.ddlDesignType.Items.Clear();
            this.ddlDesignType.Items.Add(new ListItem("Select a Design Type", "0"));
            List<DesignTypeBO> lstDesignTypes = (new DesignTypeBO()).GetAllObject().ToList();
            foreach (DesignTypeBO dt in lstDesignTypes)
            {
                this.ddlDesignType.Items.Add(new ListItem(dt.Name, dt.ID.ToString()));
            }

            // populate Units
            this.ddlUnits.Items.Clear();
            this.ddlUnits.Items.Add(new ListItem("Select a Unit", "0"));
            List<UnitBO> lstUnits = (new UnitBO()).GetAllObject().ToList();
            foreach (UnitBO unit in lstUnits)
            {
                this.ddlUnits.Items.Add(new ListItem(unit.Name, unit.ID.ToString()));
            }

            if (this.QueryID == 0)
            {
                this.txtDateQuoted.Text = DateTime.Now.ToString("dd MMMM yyyy");
                this.ddlStatus.Enabled = false;
                this.lblQuoteStatus.Visible = false;
                this.PopulateQuoteDetail(0);

                this.ddlStatus.SelectedValue = "1";
                this.ddlCurrency.SelectedValue = "1";
            }
            else
            {
                QuoteBO objQuote = new QuoteBO();
                objQuote.ID = this.QueryID;
                objQuote.GetObject();

                this.txtDateQuoted.Text = objQuote.DateQuoted.ToString("dd MMMM yyyy");
                this.txtContactName.Text = objQuote.ContactName;
                this.txtClientEmail.Text = objQuote.ClientEmail;
                this.txtJobName.Text = objQuote.JobName;
               // this.ddlDistributor.Items.FindByValue((objQuote.Distributor != null && objQuote.Distributor > 0) ? objQuote.Distributor.ToString() : "0").Selected = true;
                this.ddlStatus.Items.FindByValue((objQuote.Status != null && objQuote.Status > 0) ? objQuote.Status.ToString() : "0").Selected = true;
                this.ddlCurrency.Items.FindByValue((objQuote.Currency != null && objQuote.Currency > 0) ? objQuote.Currency.ToString() : "0").Selected = true;
                this.txtQuoteExpiryDate.Text = objQuote.QuoteExpiryDate.ToString("dd MMMM yyyy");
                
                this.PopulateQuoteDetail(this.QueryID);

                //this.PopulatePatterns(this.QueryID);

                //this.PopulateFabrics(this.QueryID);

                this.collapse2.Attributes.Add("class", "accordion-body collapse in");
            }

        }

        private void ProcessForm(bool isQuoteDetail, int quotedetail = 0)
        {
            try
            {
                //int QuoteID = 0;
                using (TransactionScope ts = new TransactionScope())
                {
                    QuoteBO objQuote = new QuoteBO(this.ObjContext);

                    if (QueryID > 0 || QuoteID > 0)
                    {
                        objQuote.ID = (QueryID > 0) ? QueryID : QuoteID;
                        objQuote.GetObject();
                    }
                    else
                    {
                        objQuote.DateQuoted = DateTime.Now;//Convert.ToDateTime(this.txtDateQuoted.Text);
                        objQuote.Creator = LoggedUser.ID;
                        objQuote.CreatedDate = DateTime.Now;
                    }

                    #region Quote Header

                    objQuote.DateQuoted = Convert.ToDateTime(this.txtDateQuoted.Text);
                    objQuote.QuoteExpiryDate = Convert.ToDateTime(this.txtQuoteExpiryDate.Text);
                    objQuote.ClientEmail = this.txtClientEmail.Text;
                    objQuote.JobName = this.txtJobName.Text;
                    //objQuote.Distributor = int.Parse(this.ddlDistributor.SelectedValue);
                    objQuote.ContactName = this.txtContactName.Text;
                    objQuote.Status = int.Parse(this.ddlStatus.SelectedValue);
                    objQuote.Currency = int.Parse(this.ddlCurrency.SelectedValue);
                    objQuote.QuoteExpiryDate = Convert.ToDateTime(this.txtQuoteExpiryDate.Text);
                    objQuote.Modifier = this.LoggedUser.ID;
                    objQuote.ModifiedDate = DateTime.Now;

                    this.ObjContext.SaveChanges();
                    QuoteID = objQuote.ID;

                    #endregion

                    #region Quote Detail

                    if (isQuoteDetail)
                    {
                        QuoteDetailBO objQuoteDetail = new QuoteDetailBO(this.ObjContext);

                        if (quotedetail > 0)
                        {
                            objQuoteDetail.ID = quotedetail;
                            objQuoteDetail.GetObject();
                        }

                        objQuoteDetail.Quote = QuoteID;
                        objQuoteDetail.Pattern = int.Parse(this.ddlPattern.SelectedValue);
                        objQuoteDetail.Fabric = int.Parse(this.ddlFabric.SelectedValue);
                        objQuoteDetail.PriceTerm = int.Parse(this.ddlPriceTerm.SelectedValue);
                        objQuoteDetail.DesignType = int.Parse(this.ddlDesignType.SelectedValue);
                        objQuoteDetail.Unit = int.Parse(this.ddlUnits.SelectedValue);
                        objQuoteDetail.IsGST = this.chkIsGST.Checked;
                        objQuoteDetail.GST = (this.chkIsGST.Checked == true) ? (!string.IsNullOrEmpty(this.txtGST.Text)) ? Convert.ToDecimal(this.txtGST.Text) : 0 : 0;
                        objQuoteDetail.IndimanPrice = (!string.IsNullOrEmpty(this.txtIndimanPrice.Text)) ? Convert.ToDecimal(this.txtIndimanPrice.Text) : 0;
                        objQuoteDetail.DesignFee = (!string.IsNullOrEmpty(this.txtDesignFee.Text)) ? Convert.ToDecimal(this.txtDesignFee.Text) : 0;
                        objQuoteDetail.Qty = (!string.IsNullOrEmpty(this.txtQty.Text)) ? int.Parse(this.txtQty.Text) : 0;
                        objQuoteDetail.Notes = this.txtNotes.Text;
                        //objQuoteDetail.VisualLayout = int.Parse(this.ddlVisualLayout.SelectedValue);

                        if (!string.IsNullOrEmpty(this.txtDeliveryDate.Text))
                        {
                            objQuoteDetail.DelivaryDate = Convert.ToDateTime(this.txtDeliveryDate.Text);
                        }

                        this.ObjContext.SaveChanges();

                        this.QuoteDetailID = 0;
                    }

                    #endregion

                    ts.Complete();


                }

                if (this.QueryID == 0)
                {
                    // this.SendMail(QuoteID);
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while saving Quotes in AddEditQuotes Page", ex);
            }
        }

        //private void SendMail(int ID)
        //{
        //    try
        //    {
        //        string mailcc = string.Empty;
        //        List<QuoteChangeEmailListBO> lstQuoteChangeEmailListCC = (new QuoteChangeEmailListBO()).SearchObjects().Where(o => o.IsCC == true).ToList();

        //        foreach (QuoteChangeEmailListBO ccList in lstQuoteChangeEmailListCC)
        //        {
        //            UserBO objUser = new UserBO();
        //            objUser.ID = (int)ccList.User;
        //            objUser.GetObject();
        //            mailcc += objUser.EmailAddress + ",";
        //        }
        //        // mailcc = "nisithamasakorala@gmail.com";
        //        string emailContent = string.Empty;
        //        string emailTemp = QuoteEmailTemplate;
        //        string emailLogoPath = string.Empty;

        //        if (!string.IsNullOrEmpty(this.txtJobName.Text))
        //        {
        //            emailContent += " <tr>" +
        //                              "<td width=\"200\" style=\"border-left:0px; border-top:0; font-size:11px; font-family: Arial; background:#CAE8EA no-repeat; color:#000000; border-left:0px solid #ffffff; border-right:0px solid #ffffff; border-bottom:0px solid #ffffff; border-top:0px solid #ffffff;  text-align:left;  background:#fff \" scope=\"row\">" + "Job Name" + "</td>" +
        //                              "<td width=\"480\" style=\"border-right:0px solid #ffffff;font-size:11px; font-family: Arial; border-bottom:0px solid #ffffff; border-top:0px solid #ffffff;  background:#fff;  color:#000000\">" + this.txtJobName.Text + "</td>" +
        //                              "</tr>";
        //        }

        //        if (int.Parse(this.ddlPattern.SelectedValue) > 0)
        //        {
        //            emailContent += " <tr>" +
        //                              "<td width=\"200\" style=\"border-left:0px; border-top:0; font-size:11px; font-family: Arial; background:#CAE8EA no-repeat; color:#000000; border-left:0px solid #ffffff; border-right:0px solid #ffffff; border-bottom:0px solid #ffffff; border-top:0px solid #ffffff;  text-align:left;  background:#fff \" scope=\"row\">" + "Item" + "</td>" +
        //                              "<td width=\"480\" style=\"border-right:0px solid #ffffff; font-size:11px; font-family: Arial; border-bottom:0px solid #ffffff; border-top:0px solid #ffffff;  background:#fff;  color:#000000\">" + this.ddlPattern.SelectedItem.Text/*this.txtPattern.Text*/ + "</td>" +
        //                              "</tr>";
        //        }

        //        if (!string.IsNullOrEmpty(this.txtIndimanPrice.Text))
        //        {
        //            string currency = string.Empty;
        //            if (int.Parse(this.ddlCurrency.SelectedValue) > 0)
        //            {
        //                CurrencyBO objCurrency = new CurrencyBO();
        //                objCurrency.ID = int.Parse(this.ddlCurrency.SelectedValue);
        //                objCurrency.GetObject();
        //                currency = objCurrency.Code;
        //            }
        //            string priceterm = (int.Parse(this.ddlPriceTerm.SelectedValue) > 0) ? this.ddlPriceTerm.SelectedItem.Text : string.Empty;
        //            emailContent += " <tr>" +
        //                             "<td width=\"200\" style=\"border-left:0px; border-top:0; font-size:11px; font-family: Arial; background:#CAE8EA no-repeat; color:#000000; border-left:0px solid #ffffff; border-right:0px solid #ffffff; border-bottom:0px solid #ffffff; border-top:0px solid #ffffff;  text-align:left;  background:#fff \" scope=\"row\">" + "Price" + "</td>" +
        //                             "<td width=\"480\" style=\"border-right:0px solid #ffffff; font-size:11px; font-family: Arial; border-bottom:0px solid #ffffff; border-top:0px solid #ffffff;  background:#fff;  color:#000000\">" + currency + " " + Convert.ToDecimal(this.txtIndimanPrice.Text).ToString("0.00") + " " + priceterm + "</td>" +
        //                             "</tr>";
        //        }

        //        if (!string.IsNullOrEmpty(this.txtQty.Text))
        //        {
        //            emailContent += " <tr>" +
        //                              "<td width=\"200\" style=\"border-left:1px; border-top:0; font-size:11px; font-family: Arial; background:#CAE8EA no-repeat; color:#000000; border-left:0px solid #ffffff; border-right:0px solid #ffffff; border-bottom:0px solid #ffffff; border-top:0px solid #ffffff;  text-align:left;  background:#fff \" scope=\"row\">" + "Indicated Quantity" + "</td>" +
        //                             "<td width=\"480\" style=\"border-right:0px solid #ffffff; font-size:11px; font-family: Arial; border-bottom:0px solid #ffffff; border-top:0px solid #ffffff;  background:#fff;  color:#000000\">" + this.txtQty.Text + "</td>" +
        //                             "</tr>";
        //        }

        //        if (!string.IsNullOrEmpty(this.txtDeliveryDate.Text))
        //        {
        //            emailContent += " <tr>" +
        //                             "<td width=\"200\" style=\"border-left:0px; border-top:0; font-size:11px; font-family: Arial; background:#CAE8EA no-repeat; color:#000000; border-left:0px solid #ffffff; border-right:0px solid #ffffff; border-bottom:0px solid #ffffff; border-top:0px solid #ffffff;  text-align:left;  background:#fff \" scope=\"row\">" + "Approx. despatch date" + "</td>" +
        //                             "<td width=\"480\" style=\"border-right:0px solid #ffffff; font-size:11px; font-family: Arial; border-bottom:0px solid #ffffff; border-top:0px solid #ffffff;  background:#fff;  color:#000000\">" + Convert.ToDateTime(this.txtDeliveryDate.Text).ToString("dd MMMM yyyy") + "</td>" +
        //                             "</tr>";
        //        }

        //        if (!string.IsNullOrEmpty(this.txtQuoteExpiryDate.Text))
        //        {
        //            emailContent += " <tr>" +
        //                            " <td width=\"200\" style=\"border-left:0px; border-top:0; font-size:11px; font-family: Arial; background:#CAE8EA no-repeat; color:#000000; border-left:0px solid #ffffff; border-right:0px solid #ffffff; border-bottom:0px solid #ffffff; border-top:0px solid #ffffff;  text-align:left;  background:#fff \" scope=\"row\">" + "Expires On" + "</td>" +
        //                            " <td width=\"480\" style=\"border-right:0px solid #ffffff; font-size:11px; font-family: Arial; border-bottom:0px solid #ffffff; border-top:0px solid #ffffff;  background:#fff;  color:#000000\">" + Convert.ToDateTime(this.txtQuoteExpiryDate.Text).ToString("dd MMMM yyyy") + "</td>" +
        //                            " </tr>";
        //        }

        //        if (!string.IsNullOrEmpty(this.txtNotes.Text))
        //        {
        //            emailContent += " <tr>" +
        //                             "<td width=\"200\" style=\"border-left:1px; border-top:0; font-size:11px; font-family: Arial; background:#CAE8EA no-repeat; color:#000000; border-left:0px solid #ffffff; border-right:0px solid #ffffff; border-bottom:0px solid #ffffff; border-top:0px solid #ffffff;  text-align:left;  background:#fff \" scope=\"row\">" + "Notes" + "</td>" +
        //                             "<td width=\"480\" style=\"border-right:0px solid #ffffff; font-size:11px; font-family: Arial; border-bottom:0px solid #ffffff; border-top:0px solid #ffffff;  background:#fff;  color:#000000\">" + this.txtNotes.Text + "</td>" +
        //                             "</tr>";
        //        }

        //        if (int.Parse(this.ddlDistributor.SelectedValue) > 0)
        //        {
        //            emailContent += " <tr>" +
        //                             "<td width=\"200\" style=\"border-left:1px; border-top:0; font-size:11px; font-family: Arial; background:#CAE8EA no-repeat; color:#000000; border-left:0px solid #ffffff; border-right:0px solid #ffffff; border-bottom:0px solid #ffffff; border-top:0px solid #ffffff;  text-align:left;  background:#fff \" scope=\"row\">" + "Distributor" + "</td>" +
        //                             "<td width=\"480\" style=\"border-right:0px solid #ffffff; font-size:11px; font-family: Arial; border-bottom:0px solid #ffffff; border-top:0px solid #ffffff;  background:#fff;  color:#000000\">" + this.ddlDistributor.SelectedItem.Text + "</td>" +
        //                             "</tr>";
        //        }

        //        emailTemp = emailTemp.Replace("<$tabledata$>", emailContent);
        //        emailTemp = emailTemp.Replace("<$contactname$>", this.txtContactName.Text);
        //        string designation = (!string.IsNullOrEmpty(LoggedUser.Designation)) ? (" | " + LoggedUser.Designation) : string.Empty;
        //        emailTemp = emailTemp.Replace("<$name$>", LoggedUser.GivenName + " " + LoggedUser.FamilyName + "" + designation);
        //        emailTemp = emailTemp.Replace(" <$email$>", LoggedUser.EmailAddress);
        //        emailTemp = emailTemp.Replace(" <$phone$>", LoggedUser.OfficeTelephoneNumber);
        //        emailTemp = emailTemp.Replace("<$Mobile$>", (LoggedUser.MobileTelephoneNumber != null && !string.IsNullOrEmpty(LoggedUser.MobileTelephoneNumber)) ? LoggedUser.MobileTelephoneNumber : string.Empty);
        //        emailTemp = emailTemp.Replace("<$fax$>", LoggedUser.objCompany.Fax);

        //        EmailLogoBO objEmailLogo = new EmailLogoBO().SearchObjects().SingleOrDefault();

        //        if (objEmailLogo != null)
        //        {
        //            emailLogoPath = IndicoConfiguration.AppConfiguration.DataFolderName + "/EmailLogos/" + objEmailLogo.EmailLogoPath;

        //            if (!File.Exists(Server.MapPath(emailLogoPath)))
        //            {
        //                emailLogoPath = IndicoConfiguration.AppConfiguration.DataFolderName + "/EmailLogos/logo_login.png";
        //            }
        //        }
        //        else
        //        {
        //            emailLogoPath = IndicoConfiguration.AppConfiguration.DataFolderName + "/EmailLogos/logo_login.png";
        //        }

        //        System.Drawing.Image emailImage = System.Drawing.Image.FromFile(Server.MapPath(emailLogoPath));
        //        SizeF emailLogo = emailImage.PhysicalDimension;
        //        emailImage.Dispose();

        //        List<float> lstVLImageDimensions = (new ImageProcess()).GetResizedImageDimensionForHeight(Convert.ToInt32(Math.Abs(emailLogo.Width)), Convert.ToInt32(Math.Abs(emailLogo.Height)), 110);

        //        emailLogoPath = "http://" + IndicoConfiguration.AppConfiguration.SiteHostAddress + "/" + emailLogoPath;
        //        emailTemp = emailTemp.Replace("<$logoimage$>", "<img src=\"" + emailLogoPath + "\" height=\"" + lstVLImageDimensions[0].ToString() + "\" width=\"" + lstVLImageDimensions[1].ToString() + "\"/>");



        //        if (!string.IsNullOrEmpty(mailcc))
        //        {
        //            IndicoEmail.SendMail(LoggedUser.GivenName + " " + LoggedUser.FamilyName, LoggedUser.EmailAddress, this.txtContactName.Text, this.txtClientEmail.Text, mailcc, "Quote: QT" + " - " + ID, null, "", false, emailTemp);
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        IndicoLogging.log.Error("Error occured while send email from AddEditQuote.aspx", ex);
        //    }

        //}

        //private void PopulatePatterns(int quote = 0, int pattern = 0)
        //{
        //    // Dictionary<int, string> patterns = (new PatternBO()).SearchObjects().AsQueryable().OrderBy(SortExpression).Where(o => o.IsActive == true).Select(o => new { Key = o.ID, Value = (o.Number + " - " + o.NickName) }).ToDictionary(o => o.Key, o => o.Value);

        //    List<PatternBO> lstPatterns = (new PatternBO()).SearchObjects().AsQueryable().OrderBy(o => o.Number).Where(o => o.IsActive == true).ToList();

        //    if (quote > 0)
        //    {
        //        QuoteDetailBO objQuoteDetails = new QuoteDetailBO();
        //        objQuoteDetails.Quote = quote;

        //        List<int> lst = lstPatterns.Select(o => o.ID).ToList();

        //        List<int> lstExistPatten = objQuoteDetails.SearchObjects().Select(o => o.Pattern).ToList();

        //        lst = (pattern > 0) ? lst.Except(lstExistPatten.Where(o => o != pattern).ToList()).ToList() : lst.Except(lstExistPatten).ToList();

        //        lstPatterns = lstPatterns.Where(o => lst.Contains(o.ID)).ToList();
        //    }

        //    Dictionary<int, string> patterns = lstPatterns.Select(o => new { Key = o.ID, Value = (o.Number + " - " + o.NickName) }).ToDictionary(o => o.Key, o => o.Value);

        //    Dictionary<int, string> dicPatterns = new Dictionary<int, string>();

        //    this.ddlPattern.Items.Clear();

        //    dicPatterns.Add(0, "Please select or type...");
        //    foreach (KeyValuePair<int, string> item in patterns)
        //    {
        //        dicPatterns.Add(item.Key, item.Value);
        //    }

        //    this.ddlPattern.DataSource = dicPatterns;
        //    this.ddlPattern.DataTextField = "Value";
        //    this.ddlPattern.DataValueField = "Key";
        //    this.ddlPattern.DataBind();
        //}

        //private void PopulateFabrics(int quote = 0, int fabric = 0)
        //{
        //    //Dictionary<int, string> fabrics = (new FabricCodeBO()).SearchObjects().AsQueryable().OrderBy(SortExpression).ToList().Select(o => new { Key = o.ID, Value = (o.Code + " - " + o.Name) }).ToDictionary(o => o.Key, o => o.Value);

        //    List<FabricCodeBO> lstFabricCodes = (new FabricCodeBO()).SearchObjects().AsQueryable().OrderBy(o => o.Code).ToList();

        //    if (quote > 0)
        //    {
        //        QuoteDetailBO objQuoteDetails = new QuoteDetailBO();
        //        objQuoteDetails.Quote = quote;

        //        List<int> lst = lstFabricCodes.Select(o => o.ID).ToList();

        //        List<int> lstExistFabric = objQuoteDetails.SearchObjects().Select(o => o.Fabric).ToList();

        //        lst = (fabric > 0) ? lst.Except(lstExistFabric.Where(o => o != fabric).ToList()).ToList() : lst.Except(lstExistFabric).ToList();

        //        lstFabricCodes = lstFabricCodes.Where(o => lst.Contains(o.ID)).ToList();

        //    }

        //    Dictionary<int, string> fabrics = lstFabricCodes.Select(o => new { Key = o.ID, Value = (o.Code + " - " + o.Name) }).ToDictionary(o => o.Key, o => o.Value);

        //    Dictionary<int, string> dicFabrics = new Dictionary<int, string>();

        //    this.ddlFabric.Items.Clear();
        //    dicFabrics.Add(0, "Please select or type...");
        //    foreach (KeyValuePair<int, string> item in fabrics)
        //    {
        //        dicFabrics.Add(item.Key, item.Value);
        //    }

        //    this.ddlFabric.DataSource = dicFabrics;
        //    this.ddlFabric.DataTextField = "Value";
        //    this.ddlFabric.DataValueField = "Key";
        //    this.ddlFabric.DataBind();
        //}

        private void SendMail(int ID)
        {
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

                    //string emailContent = CheckQuotes.CreateQuoteDetailBody(objQuote);
                    //string emailTemp = QuoteEmailTemplate;
                    //string emailTemp = CheckQuotes.CreateQuoteDetailBody(objQuote);

                    string emailTemp = GenerateOdsPdf.CreateQuoteDetail(objQuote);
                    string emailLogoPath = string.Empty;

                    string[] attachment = { GenerateOdsPdf.CreateQuoteDetailAttachments(QuoteID) };

                    if (!string.IsNullOrEmpty(mailcc))
                    {
                        //GenerateOdsPdf.GenerateQuoteDetail(QuoteID);
                        mailcc += LoggedUser.EmailAddress + ",";
                        IndicoEmail.SendMail(LoggedUser.GivenName + " " + LoggedUser.FamilyName, LoggedUser.EmailAddress, objQuote.ContactName, objQuote.ClientEmail, mailcc, "Quote: QT" + " - " + QuoteID, null, attachment, false, emailTemp);
                    }
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error Occured While sending the Quote Detail Mail", ex);
                }
            }
        }

        private void PopulatePatterns()
        {
            Dictionary<int, string> patterns = (new PatternBO()).SearchObjects().AsQueryable().OrderBy(SortExpression).Where(o => o.IsActive == true).Select(o => new { Key = o.ID, Value = (o.Number + " - " + o.NickName) }).ToDictionary(o => o.Key, o => o.Value);

            Dictionary<int, string> dicPatterns = new Dictionary<int, string>();

            this.ddlPattern.Items.Clear();

            dicPatterns.Add(0, "Please select or type...");
            foreach (KeyValuePair<int, string> item in patterns)
            {
                dicPatterns.Add(item.Key, item.Value);
            }

            this.ddlPattern.DataSource = dicPatterns;
            this.ddlPattern.DataTextField = "Value";
            this.ddlPattern.DataValueField = "Key";
            this.ddlPattern.DataBind();
        }

        private void PopulateFabrics()
        {
            Dictionary<int, string> fabrics = (new FabricCodeBO()).SearchObjects().AsQueryable().OrderBy(SortExpression).ToList().Select(o => new { Key = o.ID, Value = (o.Code + " - " + o.Name) }).ToDictionary(o => o.Key, o => o.Value);

            Dictionary<int, string> dicFabrics = new Dictionary<int, string>();

            this.ddlFabric.Items.Clear();
            dicFabrics.Add(0, "Please select or type...");
            foreach (KeyValuePair<int, string> item in fabrics)
            {
                dicFabrics.Add(item.Key, item.Value);
            }

            this.ddlFabric.DataSource = dicFabrics;
            this.ddlFabric.DataTextField = "Value";
            this.ddlFabric.DataValueField = "Key";
            this.ddlFabric.DataBind();
        }

        private void PopulateQuoteDetail(int quote)
        {
            if (quote > 0)
            {
                QuoteDetailBO objQuoteDetail = new QuoteDetailBO();
                objQuoteDetail.Quote = quote;

                List<QuoteDetailBO> lstQuoteDeails = objQuoteDetail.SearchObjects().ToList();

                if (lstQuoteDeails.Count > 0)
                {
                    this.dgQuoteDetails.DataSource = lstQuoteDeails;
                    this.dgQuoteDetails.DataBind();
                }

                this.dgQuoteDetails.Visible = (lstQuoteDeails.Count > 0) ? true : false;
                this.dvNoQuotes.Visible = (lstQuoteDeails.Count > 0) ? false : true;
            }
            else
            {
                this.dvNoQuotes.Visible = true;
                this.dgQuoteDetails.Visible = false;
            }
        }

        //private void PopulateVisualLayout(int pattern, int fabric)
        //{
        //    if (pattern > 0 && fabric > 0)
        //    {
        //        VisualLayoutBO objVisualLayout = new VisualLayoutBO();
        //        objVisualLayout.Pattern = pattern;
        //        objVisualLayout.FabricCode = fabric;

        //        List<VisualLayoutBO> lstVisualLayouts = objVisualLayout.SearchObjects().ToList();

        //        this.ddlVisualLayout.Items.Clear();
        //        this.ddlVisualLayout.Items.Add(new ListItem("Select a VisualLayout", "0"));

        //        if (lstVisualLayouts.Count > 0)
        //        {
        //            this.ddlVisualLayout.Items.Clear();
        //            this.ddlVisualLayout.Items.Add(new ListItem("Select a VisualLayout", "0"));
        //            foreach (VisualLayoutBO vl in lstVisualLayouts)
        //            {
        //                this.ddlVisualLayout.Items.Add(new ListItem(vl.NamePrefix, vl.ID.ToString()));
        //            }
        //        }
        //    }
        //}

        private bool CheckExsistsPattenFabric(int pattern, int fabric, int Quote)
        {
            List<QuoteDetailBO> lst = new List<QuoteDetailBO>();

            if (pattern > 0 && fabric > 0 && Quote > 0)
            {
                QuoteDetailBO objQuoteDetail = new QuoteDetailBO();
                objQuoteDetail.Quote = Quote;
                objQuoteDetail.Pattern = pattern;
                objQuoteDetail.Fabric = fabric;

                lst = objQuoteDetail.SearchObjects();

                this.lblErrorMeassage.Visible = (lst.Count > 0) ? true : false;
                this.lblErrorMeassage.Text = "This Pattern and Fabric already in the system";


                if (lst.Count > 0)
                {
                    this.ddlFabric.Items.FindByValue(this.ddlFabric.SelectedValue).Selected = false;
                    this.ddlFabric.Items.FindByValue("0").Selected = true;
                }
            }

            return (lst.Count > 0) ? true : false;
        }

        #endregion
    }
}