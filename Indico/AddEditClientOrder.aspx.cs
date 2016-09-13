using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Transactions;
using System.Drawing;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Threading;

using Indico.BusinessObjects;
using Indico.Common;

namespace Indico
{
    public partial class AddEditClientOrder : IndicoPage
    {
        #region Fields

        private int urlQueryID = -1;

        #endregion

        #region Properties

        protected int QueryID
        {
            get
            {
                urlQueryID = 0;

                if (Request.QueryString["id"] != null)
                    urlQueryID = Convert.ToInt32(Request.QueryString["id"].ToString());
                else if ((ViewState["OrderID_" + this.LoggedUser.ID.ToString()] != null) && (urlQueryID == 0))
                    urlQueryID = int.Parse(ViewState["OrderID_" + this.LoggedUser.ID.ToString()].ToString());

                return urlQueryID;
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

        protected void rptSizeQty_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is SizeBO)
            {
                SizeBO objSize = (SizeBO)item.DataItem;

                HiddenField hdnQtyID = (HiddenField)item.FindControl("hdnQtyID");
                hdnQtyID.Value = "0";

                Literal litHeading = (Literal)item.FindControl("litHeading");
                litHeading.Text = objSize.SizeName;

                TextBox txtQty = (TextBox)item.FindControl("txtQty");
                txtQty.Text = "0";
                txtQty.Attributes.Add("Size", objSize.ID.ToString());
                //txtQty.Attributes.Add("OnChange", "calculateTotal(this);");
                //txtQty.Attributes.Add("OnKeyDown", "allowNumaricOnly();");                
            }
            else if (item.ItemIndex > -1 && item.DataItem is OrderDetailQtyBO)
            {
                OrderDetailQtyBO objClientOrderQty = (OrderDetailQtyBO)item.DataItem;

                HiddenField hdnQtyID = (HiddenField)item.FindControl("hdnQtyID");
                hdnQtyID.Value = objClientOrderQty.ID.ToString();

                Literal litHeading = (Literal)item.FindControl("litHeading");
                litHeading.Text = objClientOrderQty.objSize.SizeName;

                TextBox txtQty = (TextBox)item.FindControl("txtQty");
                txtQty.Text = objClientOrderQty.Qty.ToString();
                txtQty.Attributes.Add("Size", objClientOrderQty.Size.ToString());
            }
        }

        protected void rptSizeQtyView_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is OrderDetailQtyBO)
            {
                OrderDetailQtyBO objClientOrderDetailOrderQty = (OrderDetailQtyBO)item.DataItem;

                Literal litHeading = (Literal)item.FindControl("litHeading");
                litHeading.Text = objClientOrderDetailOrderQty.objSize.SizeName;

                Label lblQty = (Label)item.FindControl("lblQty");
                lblQty.Text = objClientOrderDetailOrderQty.Qty.ToString();
            }
        }

        //protected void rptOrderItems_ItemDataBound(object sender, RepeaterItemEventArgs e)
        //{
        //    RepeaterItem item = e.Item;
        //    if (item.ItemIndex > -1 && item.DataItem is ClientOrderDetailBO)
        //    {
        //        ClientOrderDetailBO objClientOrderDetail = (ClientOrderDetailBO)item.DataItem;

        //        Label lblOrderType = (Label)item.FindControl("lblOrderType");
        //        lblOrderType.Text = objClientOrderDetail.objOrderType.Name;

        //        Label lblVLNumber = (Label)item.FindControl("lblVLNumber");
        //        lblVLNumber.Text = objClientOrderDetail.objVisualLayout.Name + " / " + objClientOrderDetail.objPattern.PatternNumber + " / " + objClientOrderDetail.objFabricCode.Name;

        //        Label lblVlNotes = (Label)item.FindControl("lblVlNotes");
        //        lblVlNotes.Text = objClientOrderDetail.VLNotes;

        //        Label lblNNP = (Label)item.FindControl("lblNNP");
        //        lblNNP.Text = objClientOrderDetail.NNP.ToString();

        //        Repeater rptSizeQtyView = (Repeater)item.FindControl("rptSizeQtyView");
        //        rptSizeQtyView.DataSource = objClientOrderDetail.ClientOrderDetailOrderQtysWhereThisIsClientOrderDetail;
        //        //rptSizeQtyView.ItemDataBound += new RepeaterItemEventHandler(rptSizeQtyView_ItemDataBound);
        //        rptSizeQtyView.DataBind();
        //    }
        //}

        protected void dgOrderItems_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            DataGridItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is OrderDetailBO)
            {
                OrderDetailBO objOrderDetail = (OrderDetailBO)item.DataItem;

                Label lblOrderType = (Label)item.FindControl("lblOrderType");
                lblOrderType.Text = objOrderDetail.objOrderType.Name;

                Label lblVLNumber = (Label)item.FindControl("lblVLNumber");
                lblVLNumber.Text = ((objOrderDetail.objVisualLayout.NameSuffix == null) ? objOrderDetail.objVisualLayout.NamePrefix : objOrderDetail.objVisualLayout.NamePrefix + objOrderDetail.objVisualLayout.NameSuffix) + " / " + objOrderDetail.objPattern.Number + " / " + objOrderDetail.objFabricCode.Name;

                HtmlAnchor ancVLImage = (HtmlAnchor)item.FindControl("ancVLImage");
                ancVLImage.HRef = IndicoPage.GetVLImagePath(objOrderDetail.VisualLayout);
                if (File.Exists(Server.MapPath(ancVLImage.HRef)))
                {
                    ancVLImage.Attributes.Add("class", "btn-link iview preview");
                    List<float> lstVLImageDimensions = (new ImageProcess()).GetResizedImageDimensions(ancVLImage.HRef);
                    if (lstVLImageDimensions.Count > 0)
                    {
                        ancVLImage.Attributes.Add("height", lstVLImageDimensions[0].ToString());
                        ancVLImage.Attributes.Add("width", lstVLImageDimensions[1].ToString());
                    }
                }
                else
                {
                    ancVLImage.Title = "Visual Layout Image Not Found";
                    ancVLImage.Attributes.Add("class", "btn-link iremove");
                }

                Repeater rptSizeQtyView = (Repeater)item.FindControl("rptSizeQtyView");
                rptSizeQtyView.DataSource = objOrderDetail.OrderDetailQtysWhereThisIsOrderDetail;
                rptSizeQtyView.DataBind();

                Label lblVlNotes = (Label)item.FindControl("lblVlNotes");
                lblVlNotes.Text = objOrderDetail.VisualLayoutNotes;

                HtmlAnchor ancNameNumberFile = (HtmlAnchor)item.FindControl("ancNameNumberFile");
                ancNameNumberFile.Attributes.Add("class", File.Exists(this.GetNameNumberFilePath(objOrderDetail.ID)) ? "btn-link iselect" : "btn-link iremove");

                HtmlAnchor linkEdit = (HtmlAnchor)item.FindControl("linkEdit");
                linkEdit.Attributes.Add("qid", objOrderDetail.ID.ToString());
                linkEdit.Visible = objOrderDetail.objOrder.IsTemporary;

                HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                linkDelete.Attributes.Add("qid", objOrderDetail.ID.ToString());
                linkDelete.Visible = objOrderDetail.objOrder.IsTemporary;
            }
        }

        protected void btnSaveChanges_Click(object sender, EventArgs e)
        {
            CustomValidator cv = null;

            #region Validate OrderItems

            if (this.dgOrderItems.Items.Count == 0)
            {
                cv = new CustomValidator();
                cv.IsValid = false;
                cv.ValidationGroup = "valGrpOrderHeader";
                cv.ErrorMessage = "No orders have been added";

                Page.Validators.Add(cv);
            }

            #endregion

            #region ValidateShipTo

            if (this.rbShipToMyClient.Checked && this.rbCourier.Checked)
            {
                if (!string.IsNullOrEmpty(this.ddlShipToMyClients.SelectedValue) && int.Parse(ddlShipToMyClients.SelectedValue) == 0)
                {
                    cv = new CustomValidator();
                    cv.IsValid = false;
                    cv.ValidationGroup = "valGrpOrderHeader";
                    cv.ErrorMessage = "Ship to Client is required";
                    Page.Validators.Add(cv);
                }
            }

            if (this.rbShipToNewClient.Checked == true && this.rbCourier.Checked == true)
            {
                if (string.IsNullOrEmpty(this.txtShipToContactName.Text))
                {
                    cv = new CustomValidator();
                    cv.IsValid = false;
                    cv.ValidationGroup = "valGrpOrderHeader";
                    cv.ErrorMessage = "Ship to Conatct Name is required";
                    Page.Validators.Add(cv);
                }

                if (string.IsNullOrEmpty(this.txtShipToAddress.Text))
                {
                    cv = new CustomValidator();
                    cv.IsValid = false;
                    cv.ValidationGroup = "valGrpOrderHeader";
                    cv.ErrorMessage = "Ship to Address is required";
                    Page.Validators.Add(cv);
                }

                if (string.IsNullOrEmpty(this.txtShipToSuburb.Text))
                {
                    cv = new CustomValidator();
                    cv.IsValid = false;
                    cv.ValidationGroup = "valGrpOrderHeader";
                    cv.ErrorMessage = "Ship to Suburb is required";
                    Page.Validators.Add(cv);
                }

                if (string.IsNullOrEmpty(this.txtShipToPostCode.Text))
                {
                    cv = new CustomValidator();
                    cv.IsValid = false;
                    cv.ValidationGroup = "valGrpOrderHeader";
                    cv.ErrorMessage = "Ship to Post Code is required";
                    Page.Validators.Add(cv);
                }

                if (string.IsNullOrEmpty(this.txtShipToPhone.Text))
                {
                    cv = new CustomValidator();
                    cv.IsValid = false;
                    cv.ValidationGroup = "valGrpOrderHeader";
                    cv.ErrorMessage = "Ship to Phone Number is required";
                    Page.Validators.Add(cv);
                }

                if (this.ddlShipToCountry.SelectedIndex == 0)
                {
                    cv = new CustomValidator();
                    cv.IsValid = false;
                    cv.ValidationGroup = "valGrpOrderHeader";
                    cv.ErrorMessage = "Ship to Country is required";
                    Page.Validators.Add(cv);
                }

                this.olDeliveryInformation.Attributes.Add("style", "display: block;");
                this.liSelectOption.Attributes.Add("style", "display: block;");
            }

            #endregion

            if (Page.IsValid)
            {
                this.ProcessForm(false);
                Response.Redirect("/ViewClientOrders.aspx");
            }
            else
            {
                this.validationSummary.Visible = !Page.IsValid;
            }
        }

        protected void btnAdd_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                try
                {
                    this.ProcessForm(true);
                    this.PopulateControls();

                    this.rptSizeQty.DataSource = null;
                    this.rptSizeQty.DataBind();

                    this.rptUploadFile.DataSource = null;
                    this.rptUploadFile.DataBind();

                    this.fsNameNumberFile.Visible = false;
                    this.hdnUploadFiles.Value = "";
                    this.txtVlNotes.Text = "";
                    this.btnAdd.Text = "Add Order Detail";
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Exception occured when adding order infomation", ex);
                }
            }

            this.PopulateFileUploder(this.rptUploadFile, this.hdnUploadFiles);
        }

        protected void btnDeleteOrderItem_Click(object sender, EventArgs e)
        {
            int orderId = int.Parse(this.hdnSelectedID.Value.Trim());

            if (orderId > 0)
            {
                try
                {
                    using (TransactionScope ts = new TransactionScope())
                    {
                        OrderDetailBO objClientOrderDetail = new OrderDetailBO(this.ObjContext);
                        objClientOrderDetail.ID = orderId;
                        objClientOrderDetail.GetObject();

                        foreach (OrderDetailQtyBO qty in objClientOrderDetail.OrderDetailQtysWhereThisIsOrderDetail)
                        {
                            OrderDetailQtyBO objClientOrderDetailOrderQty = new OrderDetailQtyBO(this.ObjContext);
                            objClientOrderDetailOrderQty.ID = qty.ID;
                            objClientOrderDetailOrderQty.GetObject();

                            objClientOrderDetailOrderQty.Delete();
                        }

                        objClientOrderDetail.Delete();

                        this.ObjContext.SaveChanges();
                        ts.Complete();
                    }
                }
                catch (Exception ex)
                {
                    throw ex;
                }
            }
            this.PopulateControls();
        }

        protected void btnDeleteOrderItems_Click(object sender, EventArgs e)
        {
            #region Delete Existing Order Details

            OrderBO objClientOrderHeader = new OrderBO();
            objClientOrderHeader.ID = this.QueryID;
            objClientOrderHeader.GetObject();

            List<OrderDetailBO> lstClientOrderDetails = objClientOrderHeader.OrderDetailsWhereThisIsOrder;

            using (TransactionScope ts = new TransactionScope())
            {
                try
                {
                    foreach (OrderDetailBO clientOrderDetail in lstClientOrderDetails)
                    {
                        OrderDetailBO objClientOrderDetail = new OrderDetailBO(this.ObjContext);
                        objClientOrderDetail.ID = clientOrderDetail.ID;
                        objClientOrderDetail.GetObject();

                        //Delete Order Quantities.
                        List<OrderDetailQtyBO> lstClientOrderDetailOrderQties = objClientOrderDetail.OrderDetailQtysWhereThisIsOrderDetail;
                        foreach (OrderDetailQtyBO orderQty in lstClientOrderDetailOrderQties)
                        {
                            OrderDetailQtyBO objClientOrderDetailOrderQty = new OrderDetailQtyBO(this.ObjContext);
                            objClientOrderDetailOrderQty.ID = orderQty.ID;
                            objClientOrderDetailOrderQty.GetObject();

                            objClientOrderDetailOrderQty.Delete();
                            this.ObjContext.SaveChanges();
                        }

                        objClientOrderDetail.Delete();
                        this.ObjContext.SaveChanges();
                    }
                    ts.Complete();
                }
                catch (Exception ex)
                {
                    throw ex;
                }
            }

            #endregion

            this.PopulateControls();

            foreach (ListItem item in this.ddlClientOrJobName.Items)
            {
                if (item.Selected)
                    this.ddlClientOrJobName.Items.FindByValue(item.Value).Selected = false;
            }
            this.ddlClientOrJobName.Items.FindByValue(this.hdnSelectedClientId.Value).Selected = true;

            //Populate VLNumber
            this.ddlVlNumber.Items.Clear();
            this.ddlVlNumber.Items.Add(new ListItem("Select Visual Layout Number", "0"));

            List<VisualLayoutBO> lstVLNumbers = (from o in (new VisualLayoutBO()).GetAllObject()
                                                 where o.Client == int.Parse(this.ddlClientOrJobName.SelectedValue)
                                                 select o).ToList();
            foreach (VisualLayoutBO vlNumber in lstVLNumbers)
            {
                string vlText = ((vlNumber.NameSuffix == null) ? vlNumber.NamePrefix : vlNumber.NamePrefix + vlNumber.NameSuffix) + " - Pattern : " + vlNumber.objPattern.Number + " - Fabric : " + vlNumber.objFabricCode.NickName;
                this.ddlVlNumber.Items.Add(new ListItem(vlText, vlNumber.ID.ToString()));
            }
            this.PopulateFileUploder(this.rptUploadFile, this.hdnUploadFiles);
        }

        protected void btnDeleteOrderItemsCancel_Click(object sender, EventArgs e)
        {
            OrderBO objOrder = new OrderBO();
            objOrder.ID = this.QueryID;
            objOrder.GetObject();

            foreach (ListItem item in this.ddlClientOrJobName.Items)
            {
                if (item.Selected)
                    this.ddlClientOrJobName.Items.FindByValue(item.Value).Selected = false;
            }
            this.ddlClientOrJobName.Items.FindByValue(objOrder.Client.ToString()).Selected = true;

            ViewState["PopulateDeleteOrdersMsg"] = false;
        }

        protected void ddlClientOrJobName_SelectedIndexChanged(object sender, EventArgs e)
        {
            this.hdnSelectedClientId.Value = this.ddlClientOrJobName.SelectedValue.ToString();

            if (this.QueryID > 0)//delete order items if exist.
            {
                OrderBO objOrder = new OrderBO();
                objOrder.ID = this.QueryID;
                objOrder.GetObject();

                if (objOrder.OrderDetailsWhereThisIsOrder.Count > 0)
                {
                    ViewState["PopulateDeleteOrdersMsg"] = true;
                    return;
                }
            }

            //Populate VL Number
            this.ddlVlNumber.Items.Clear();

            if (int.Parse(this.ddlClientOrJobName.SelectedValue) > 0)
            {
                this.ddlVlNumber.Items.Add(new ListItem("Select Visual Layout Number", "0"));

                List<VisualLayoutBO> lstVLNumbers = (from o in (new VisualLayoutBO()).GetAllObject()
                                                     where o.Client == int.Parse(this.ddlClientOrJobName.SelectedValue)
                                                     select o).ToList();
                foreach (VisualLayoutBO vlNumber in lstVLNumbers)
                {
                    string vlText = ((vlNumber.NameSuffix == null) ? vlNumber.NamePrefix : vlNumber.NamePrefix + vlNumber.NameSuffix) + " - Pattern : " + vlNumber.objPattern.Number + " - Fabric : " + vlNumber.objFabricCode.NickName;
                    this.ddlVlNumber.Items.Add(new ListItem(vlText, vlNumber.ID.ToString()));
                }

                this.hdnSelectedID.Value = "0";
                this.ddlOrderType.SelectedIndex = 0;
                this.ddlVlNumber.SelectedIndex = 0;
                this.ddlVlNumber.Enabled = true;
                this.txtVLSearch.Disabled = false;
                this.txtVlNotes.Text = "";
                this.ancVlImagePreview.Visible = false;
                this.fsNameNumberFile.Visible = false;

                this.btnAdd.Text = "Add Order Detail";
            }
            else
            {
                this.ddlVlNumber.Enabled = false;
                this.txtVLSearch.Disabled = true;
            }

            this.rptSizeQty.DataSource = null;
            this.rptSizeQty.DataBind();

            this.rptUploadFile.DataSource = null;
            this.rptUploadFile.DataBind();
        }

        protected void ddlVlNumber_SelectedIndexChange(object sender, EventArgs e)
        {
            int VisualLayout = int.Parse(this.ddlVlNumber.SelectedValue);
            if (VisualLayout > 0)
            {
                VisualLayoutBO objVLNumber = new VisualLayoutBO();
                objVLNumber.ID = VisualLayout;
                objVLNumber.GetObject();

                this.ancVlImagePreview.Visible = true;
                this.ancVlImagePreview.HRef = IndicoPage.GetVLImagePath(objVLNumber.ID);
                if (File.Exists(Server.MapPath(this.ancVlImagePreview.HRef)))
                {
                    this.ancVlImagePreview.Attributes.Add("class", "btn-link iview preview");
                    List<float> lstVLImageDimensions = (new ImageProcess()).GetOriginalImageDimensions(this.ancVlImagePreview.HRef);
                    if (lstVLImageDimensions.Count > 0)
                    {
                        this.ancVlImagePreview.Attributes.Add("height", lstVLImageDimensions[0].ToString());
                        this.ancVlImagePreview.Attributes.Add("width", lstVLImageDimensions[1].ToString());
                    }
                }
                else
                {
                    this.ancVlImagePreview.Title = "Visual Layout Image Not Found";
                    this.ancVlImagePreview.Attributes.Add("class", "btn-link iremove");
                }

                List<SizeBO> lstSizes = objVLNumber.objPattern.objSizeSet.SizesWhereThisIsSizeSet;
                this.rptSizeQty.DataSource = lstSizes;
                this.rptSizeQty.DataBind();

                //ViewState["PopulateOrderUI"] = true;
            }
            else
            {
                this.ancVlImagePreview.Visible = false;
                this.rptSizeQty.DataSource = null;
                this.rptSizeQty.DataBind();
            }

            this.PopulateFileUploder(this.rptUploadFile, this.hdnUploadFiles);
        }

        protected void linkEdit_Click(object sender, EventArgs e)
        {
            try
            {
                OrderDetailBO objOrderDetail = new OrderDetailBO();
                objOrderDetail.ID = int.Parse(((HtmlAnchor)sender).Attributes["qid"].ToString());
                objOrderDetail.GetObject();

                this.hdnSelectedID.Value = objOrderDetail.ID.ToString();

                foreach (ListItem item in ddlOrderType.Items)
                {
                    if (item.Selected)
                        this.ddlOrderType.Items.FindByValue(item.Value).Selected = false;
                }

                foreach (ListItem item in ddlVlNumber.Items)
                {
                    if (item.Selected)
                        this.ddlVlNumber.Items.FindByValue(item.Value).Selected = false;
                }

                if (!string.IsNullOrEmpty(objOrderDetail.NameAndNumbersFilePath))
                {
                    string NameAndNumberFilePath = IndicoConfiguration.AppConfiguration.DataFolderName + "/NameAndNumbersFiles/" + objOrderDetail.Order.ToString() + "/" + objOrderDetail.ID.ToString() + "/" + objOrderDetail.NameAndNumbersFilePath;
                    string Extension = Path.GetExtension(IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + NameAndNumberFilePath).Replace(".", string.Empty);
                    string NameAndNumberFileIconPath = IndicoConfiguration.AppConfiguration.DataFolderName + "/FileTypes/" + Extension + ".gif";

                    this.lblNameNumberFileName.Text = Path.GetFileName(IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + NameAndNumberFilePath);

                    if (!File.Exists(IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + NameAndNumberFileIconPath))
                        NameAndNumberFileIconPath = IndicoConfiguration.AppConfiguration.DataFolderName + "/FileTypes/unknown.gif";

                    if (!File.Exists(IndicoConfiguration.AppConfiguration.PathToProjectFolder + "/" + NameAndNumberFilePath))
                    {
                        NameAndNumberFileIconPath = IndicoConfiguration.AppConfiguration.DataFolderName + "/NameAndNumbersFiles/no_files_found.jpg";
                        this.lblNameNumberFileName.Visible = false;
                    }

                    this.fsNameNumberFile.Visible = true;
                    this.imgNameNumberFile.ImageUrl = NameAndNumberFileIconPath;
                }

                this.ddlOrderType.Items.FindByValue(objOrderDetail.OrderType.ToString()).Selected = true;

                this.ddlVlNumber.Items.FindByValue(objOrderDetail.VisualLayout.ToString()).Selected = true;
                this.ancVlImagePreview.HRef = IndicoPage.GetVLImagePath(objOrderDetail.VisualLayout);
                if (File.Exists(Server.MapPath(this.ancVlImagePreview.HRef)))
                {
                    this.ancVlImagePreview.Attributes.Add("class", "btn-link iview preview");
                    List<float> lstVLImageDimensions = (new ImageProcess()).GetOriginalImageDimensions(this.ancVlImagePreview.HRef);
                    if (lstVLImageDimensions.Count > 0)
                    {
                        this.ancVlImagePreview.Visible = true;
                        this.ancVlImagePreview.Attributes.Add("height", lstVLImageDimensions[0].ToString());
                        this.ancVlImagePreview.Attributes.Add("width", lstVLImageDimensions[1].ToString());
                    }
                }
                else
                {
                    this.ancVlImagePreview.Title = "Visual Layout Image Not Found";
                    this.ancVlImagePreview.Attributes.Add("class", "btn-link iremove");
                }

                this.rptSizeQty.DataSource = objOrderDetail.OrderDetailQtysWhereThisIsOrderDetail;
                this.rptSizeQty.DataBind();
                this.txtVlNotes.Text = objOrderDetail.VisualLayoutNotes;
                //this.chkPrintNamesNumbers.Checked = objClientOrderDetail.NNP;

                this.btnAdd.Text = "Update Order Detail";
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        #endregion

        #region Methods

        /// <summary>
        /// Populate the controls.
        /// </summary>
        private void PopulateControls()
        {
            //ViewState["PopulateOrderUI"] = false;
            ViewState["PopulateDeleteOrdersMsg"] = false;

            //Header Text
            this.litHeaderText.Text = (this.QueryID > 0) ? "Edit Order" : "New Order";

            this.litCoordinator.Text = "Your coordinator is " + this.LoggedCompany.objCoordinator.GivenName + " " + this.LoggedCompany.objCoordinator.FamilyName;

            this.txtDate.Text = DateTime.Now.ToString("dd MMM yyyy");
            this.txtDesiredDate.Text = DateTime.Now.AddDays(7 * 4).ToString("dd MMM yyyy");

            this.lblMyAddress.InnerText = this.LoggedCompany.Number + ", " + this.LoggedCompany.Address1 + ", " + this.LoggedCompany.City + ", " + this.LoggedCompany.State + ", " + this.LoggedCompany.Postcode + ", " + this.LoggedCompany.objCountry.ShortName;

            //Populate Client
            this.ddlClientOrJobName.Items.Clear();
            this.ddlClientOrJobName.Items.Add(new ListItem("Select Client or Job Name", "0"));
            List<ClientBO> lstClients = this.LoggedCompany.ClientsWhereThisIsDistributor.OrderBy(o => o.Name).ToList();
            foreach (ClientBO client in lstClients)
            {
                this.ddlClientOrJobName.Items.Add(new ListItem(client.Name, client.ID.ToString()));
            }

            //Populate Order Type
            this.ddlOrderType.Items.Clear();
            this.ddlOrderType.Items.Add(new ListItem("Select Order Type", "0"));
            List<OrderTypeBO> lstOrderTypes = (new OrderTypeBO()).GetAllObject().Where(o => o.Name.ToLower() != "free sample" && o.Name.ToLower() != "replacement").ToList();
            foreach (OrderTypeBO orderType in lstOrderTypes)
            {
                this.ddlOrderType.Items.Add(new ListItem(orderType.Name, orderType.ID.ToString()));
            }

            // Populate Country
            this.ddlShipToCountry.Items.Clear();
            this.ddlShipToCountry.Items.Add(new ListItem("Select Shipping Client Country", "0"));
            List<CountryBO> lstCountries = (new CountryBO()).GetAllObject().OrderBy(o => o.ShortName).ToList();
            foreach (CountryBO country in lstCountries)
            {
                this.ddlShipToCountry.Items.Add(new ListItem(country.ShortName, country.ID.ToString()));
            }

            this.PopulateShipToCompanyName(this.LoggedCompany.ID);

            if (this.QueryID > 0)
            {
                OrderBO objClientOrder = new OrderBO();
                objClientOrder.ID = this.QueryID;
                objClientOrder.GetObject();

                #region Disable all controls

                if (objClientOrder.IsTemporary == false)
                {
                    foreach (Control control in this.dvPageContent.Controls)
                    {
                        if (control is TextBox)
                            ((TextBox)control).Enabled = false;
                        else if (control is DropDownList)
                            ((DropDownList)control).Enabled = false;
                        else if (control is RadioButtonList)
                            ((RadioButtonList)control).Enabled = false;
                        else if (control is Button)
                            ((Button)control).Visible = false;
                        else if (control is HtmlButton)
                            ((HtmlButton)control.FindControl("btnAddOrder")).Visible = false;
                    }
                }

                #endregion

                this.txtDate.Text = objClientOrder.Date.ToString("dd MMM yyyy");
                //this.txtDesiredDate.Text = (objClientOrder.DesiredDeliveryDate != null) ? ((DateTime)objClientOrder.DesiredDeliveryDate).ToString("dd MMMM yyyy") : string.Empty;//objClientOrder.DesiredDeliveryDate.ToString("dd MMM yyyy");
                this.txtRefference.Text = objClientOrder.ID.ToString();

                this.rbAdelaideOffice.Checked = (objClientOrder.IsWeeklyShipment != null && (bool)objClientOrder.IsWeeklyShipment);
                this.rbCourier.Checked = (objClientOrder.IsCourierDelivery != null && (bool)objClientOrder.IsCourierDelivery);
                this.rbShipToMe.Checked = (objClientOrder.IsShipToDistributor != null && (bool)objClientOrder.IsShipToDistributor);
                this.rbShipToMyClient.Checked = (objClientOrder.IsShipExistingDistributor != null && (bool)objClientOrder.IsShipExistingDistributor);
                this.rbShipToNewClient.Checked = (objClientOrder.IsShipNewClient != null && (bool)objClientOrder.IsShipNewClient);

                foreach (ListItem item in this.ddlClientOrJobName.Items)
                {
                    if (item.Selected)
                        this.ddlClientOrJobName.Items.FindByValue(item.Value).Selected = false;
                }
                this.ddlClientOrJobName.Items.FindByValue(objClientOrder.Client.ToString()).Selected = true;

                //Populate VLNumber
                this.txtVLSearch.Disabled = !this.ddlVlNumber.Enabled;
                this.ddlVlNumber.Enabled = (int.Parse(this.ddlClientOrJobName.SelectedValue) > 0);
                this.ddlVlNumber.Items.Clear();
                this.ddlVlNumber.Items.Add(new ListItem("Select Visual Layout Number", "0"));
                List<VisualLayoutBO> lstVLNumbers = (new VisualLayoutBO()).GetAllObject().Where(o => o.Client == int.Parse(this.ddlClientOrJobName.SelectedValue)).ToList();
                foreach (VisualLayoutBO vlNumber in lstVLNumbers)
                {
                    string vlText = ((vlNumber.NameSuffix == null) ? vlNumber.NamePrefix : vlNumber.NamePrefix + vlNumber.NameSuffix) + " - Pattern : " + vlNumber.objPattern.Number + " - Fabric : " + vlNumber.objFabricCode.NickName;
                    this.ddlVlNumber.Items.Add(new ListItem(vlText, vlNumber.ID.ToString()));
                }

                //Populate OrderItems
                this.dgOrderItems.DataSource = objClientOrder.OrderDetailsWhereThisIsOrder;
                this.dgOrderItems.DataBind();
                this.dgOrderItems.Columns[6].Visible = objClientOrder.IsTemporary;
                this.dgOrderItems.Columns[7].Visible = objClientOrder.IsTemporary;
                this.dgOrderItems.Visible = (objClientOrder.OrderDetailsWhereThisIsOrder.Count > 0);
                this.dvNoOrders.Visible = !(objClientOrder.OrderDetailsWhereThisIsOrder.Count > 0);

                // populate ship to details
                //if (objClientOrder.IsCourierDelivery == true && (objClientOrder.ShipToExistingClient != null && objClientOrder.ShipToExistingClient > 0))
                //{
                //    DistributorClientAddressBO objDistributorClientAddress = new DistributorClientAddressBO();
                //    objDistributorClientAddress.ID = int.Parse(objClientOrder.ShipToExistingClient.ToString());
                //    objDistributorClientAddress.GetObject();

                //    this.txtShipToContactName.Text = objDistributorClientAddress.ContactName;
                //    this.txtShipToAddress.Text = objDistributorClientAddress.Address;
                //    this.txtShipToSuburb.Text = objDistributorClientAddress.Suburb;
                //    this.txtShipToPostCode.Text = objDistributorClientAddress.PostCode;
                //    this.ddlShipToCountry.Items.FindByValue(objDistributorClientAddress.Country.ToString()).Selected = true;
                //    this.txtShipToPhone.Text = objDistributorClientAddress.ContactPhone;
                //}
            }
        }

        /// <summary>
        /// Process the page data.
        /// </summary>
        private void ProcessForm(bool isTemp)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    string NNFileName = this.hdnUploadFiles.Value.Split(',')[0];
                    OrderDetailBO objClientOrderDetail = new OrderDetailBO(this.ObjContext);

                    #region Create Client Order Header

                    OrderBO objOrder = new OrderBO(this.ObjContext);

                    if (this.QueryID > 0)
                    {
                        objOrder.ID = this.QueryID;
                        objOrder.GetObject();
                    }

                   // objOrder.OrderNumber = this.txtRefference.Text;
                    objOrder.Date = Convert.ToDateTime(this.txtDate.Text);                    
                    objOrder.OrderSubmittedDate = Convert.ToDateTime(this.txtDate.Text);
                    objOrder.EstimatedCompletionDate = Convert.ToDateTime(this.txtDesiredDate.Text);
                    objOrder.Client = int.Parse(this.ddlClientOrJobName.SelectedValue);
                    objOrder.Distributor = this.LoggedCompany.ID;
                    objOrder.Status = (isTemp) ? 1 : 2;
                    objOrder.IsTemporary = isTemp;
                    objOrder.Modifier = this.LoggedUser.ID;
                    objOrder.ModifiedDate = DateTime.Now;
                    if (this.QueryID == 0)
                    {
                        objOrder.Creator = this.LoggedUser.ID;
                        objOrder.CreatedDate = DateTime.Now;
                    }

                    #region SaveShipTo

                    objOrder.IsWeeklyShipment = (this.rbAdelaideOffice.Checked);
                    objOrder.IsCourierDelivery = (this.rbCourier.Checked);
                    objOrder.IsShipToDistributor = (this.rbShipToMe.Checked);
                    objOrder.IsShipExistingDistributor = (this.rbShipToMyClient.Checked);
                    objOrder.IsShipNewClient = (this.rbShipToNewClient.Checked);

                    if (this.rbCourier.Checked == true)
                    {
                        if (this.rbShipToMe.Checked)
                        {
                            objOrder.ShipTo = this.LoggedCompany.ID;
                        }
                        //if (this.rbShipToMyClient.Checked)
                        //{
                        //    objOrder.ShipToExistingClient = int.Parse(this.ddlShipToMyClients.SelectedValue);
                        //}
                        //if (this.rbShipToNewClient.Checked)
                        //{
                        //    DistributorClientAddressBO objDistributorClientAddress = new DistributorClientAddressBO(this.ObjContext);
                        //    if (objOrder.ShipToExistingClient > 0)
                        //    {
                        //        objDistributorClientAddress.ID = objOrder.ShipToExistingClient.Value;
                        //        objDistributorClientAddress.GetObject();
                        //    }

                            
                        //    //objDistributorClientAddress.Distributor = this.LoggedCompany.ID;
                        //    objDistributorClientAddress.ContactName = this.txtShipToContactName.Text;
                        //    objDistributorClientAddress.Address = this.txtShipToAddress.Text;
                        //    objDistributorClientAddress.Suburb = this.txtShipToSuburb.Text;
                        //    objDistributorClientAddress.PostCode = this.txtShipToPostCode.Text;
                        //    objDistributorClientAddress.Country = int.Parse(this.ddlShipToCountry.SelectedValue);
                        //    objDistributorClientAddress.ContactPhone = this.txtShipToPhone.Text;

                        //    objDistributorClientAddress.OrdersWhereThisIsShipToExistingClient.Add(objOrder);
                        //}
                    }

                    #endregion

                    this.ObjContext.SaveChanges();

                    #endregion

                    if (isTemp)
                    {
                        VisualLayoutBO objVlNumber = new VisualLayoutBO();
                        objVlNumber.ID = int.Parse(this.ddlVlNumber.SelectedValue);
                        objVlNumber.GetObject();

                        #region Client Order details

                        int orderId = int.Parse(this.hdnSelectedID.Value);

                        if (orderId > 0)
                        {
                            objClientOrderDetail.ID = orderId;
                            objClientOrderDetail.GetObject();

                            if (int.Parse(this.ddlVlNumber.SelectedValue) != objClientOrderDetail.VisualLayout) //Delete existing order quatities
                            {
                                List<OrderDetailQtyBO> lstOrderQtyTmp = objClientOrderDetail.OrderDetailQtysWhereThisIsOrderDetail;
                                foreach (OrderDetailQtyBO orderQty in lstOrderQtyTmp)
                                {
                                    OrderDetailQtyBO objOrderQtyTmp = new OrderDetailQtyBO(this.ObjContext);
                                    objOrderQtyTmp.ID = orderQty.ID;
                                    objOrderQtyTmp.GetObject();

                                    objOrderQtyTmp.Delete();
                                    this.ObjContext.SaveChanges();
                                }
                            }
                            if (NNFileName != string.Empty && !string.IsNullOrEmpty(objClientOrderDetail.NameAndNumbersFilePath))
                            {
                                string oldFilieLocation = IndicoConfiguration.AppConfiguration.PathToDataFolder + "/NameAndNumbersFiles/" + objClientOrderDetail.Order.ToString() + "/" + objClientOrderDetail.ID.ToString() + "/" + objClientOrderDetail.NameAndNumbersFilePath;
                                if (File.Exists(oldFilieLocation))
                                {
                                    try
                                    {
                                        File.Delete(oldFilieLocation);
                                    }
                                    catch { }
                                }
                            }
                        }

                        foreach (RepeaterItem item in this.rptSizeQty.Items)
                        {
                            OrderDetailQtyBO objOrderDetailQty = new OrderDetailQtyBO(this.ObjContext);

                            if (objClientOrderDetail.ID != 0) //Order is in edit mode
                            {
                                if (int.Parse(this.ddlVlNumber.SelectedValue) == objClientOrderDetail.VisualLayout)
                                {
                                    int orderQtyId = int.Parse(((HiddenField)item.FindControl("hdnQtyID")).Value);
                                    if (orderQtyId > 0)
                                    {
                                        objOrderDetailQty.ID = orderQtyId;
                                        objOrderDetailQty.GetObject();
                                    }
                                }
                            }

                            TextBox txtQty = (TextBox)item.FindControl("txtQty");

                            objOrderDetailQty.Size = int.Parse(txtQty.Attributes["Size"]);
                            objOrderDetailQty.Qty = int.Parse(txtQty.Text);

                            objClientOrderDetail.OrderDetailQtysWhereThisIsOrderDetail.Add(objOrderDetailQty);
                        }

                        objClientOrderDetail.OrderType = int.Parse(this.ddlOrderType.SelectedValue);
                        objClientOrderDetail.VisualLayout = objVlNumber.ID;
                        objClientOrderDetail.NameAndNumbersFilePath = NNFileName; //File goes to --> /NameAndNumbersFiles/ClientOrderHeaderID/ClientOrderDetailID/FileName
                        objClientOrderDetail.Pattern = objVlNumber.Pattern;
                        objClientOrderDetail.FabricCode = objVlNumber.FabricCode ?? 0;
                        objClientOrderDetail.VisualLayoutNotes = this.txtVlNotes.Text.ToString();
                        objClientOrderDetail.Order = objOrder.ID;
                        if (orderId == 0)
                            objClientOrderDetail.Add();

                        #endregion
                    }

                    this.ObjContext.SaveChanges();

                    //Send Email
                    if (isTemp == false)
                    {
                        new Thread(new ThreadStart(SendEmail)).Start();
                    }

                    ts.Complete();

                    ViewState["OrderID_" + this.LoggedUser.ID.ToString()] = (this.QueryID == 0) ? objOrder.ID.ToString() : this.QueryID.ToString();

                    string NNFileSourceLocetion = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\Temp\\" + NNFileName;
                    string NNFileDestinationPath = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\NameAndNumbersFiles\\" + objOrder.ID.ToString() + "\\" + objClientOrderDetail.ID.ToString();

                    if (NNFileName != string.Empty)
                    {
                        if (File.Exists(NNFileDestinationPath + "\\" + NNFileName))
                            File.Delete(NNFileDestinationPath + "\\" + NNFileName);
                        else
                        {
                            if (!Directory.Exists(NNFileDestinationPath))
                                Directory.CreateDirectory(NNFileDestinationPath);
                            File.Copy(NNFileSourceLocetion, NNFileDestinationPath + "\\" + NNFileName);
                            //IndicoPage.ClearTemp();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        private void SendEmail()
        {
            try
            {
                string reciveremail = this.LoggedCompany.objCoordinator.EmailAddress;
                string recivername = this.LoggedCompany.objCoordinator.GivenName;

                string hostUrl = IndicoConfiguration.AppConfiguration.SiteHostAddress + "/";
                string emailContent = "New Order has been placed";
                IndicoEmail.SendMailNotificationsToExternalUsers(this.LoggedUser, reciveremail, recivername, "New Order has been placed", emailContent);

            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while send client order email", ex);
            }
        }

        private void PopulateShipToCompanyName(int CompanyID)
        {
            CompanyBO objCompany = new CompanyBO();
            objCompany.ID = CompanyID;
            objCompany.GetObject();

            if (objCompany.Number != null && objCompany.Address1 != null && objCompany.City != null && objCompany.State != null && objCompany.Postcode != null)
            {
                this.lblMyAddress.Visible = true;
                this.lblMyAddress.InnerText = objCompany.Number + ", " + objCompany.Address1 + ", " + objCompany.City + ", " + objCompany.State + ", " + objCompany.Postcode + ", " + objCompany.objCountry.ShortName;

                this.ddlShipToMyClients.Enabled = true;
                this.ddlShipToMyClients.Items.Clear();
                this.ddlShipToMyClients.Items.Add(new ListItem("Select Your Client Address", "0"));

                //DistributorClientAddressBO objDistributorClientAddress = new DistributorClientAddressBO();
                //objDistributorClientAddress.Distributor = CompanyID;
                //List<DistributorClientAddressBO> lstDistributorClientAddress = objDistributorClientAddress.SearchObjects().ToList();
              /*  List<DistributorClientAddressBO> lstDistributorClientAddress = objCompany.DistributorClientAddresssWhereThisIsDistributor.OrderBy(o => o.ContactName).ToList();
                foreach (DistributorClientAddressBO dcAddress in lstDistributorClientAddress)
                {
                    this.ddlShipToMyClients.Items.Add(new ListItem(dcAddress.ContactName, dcAddress.ID.ToString()));
                }*/
            }

            this.dvCourier.Attributes.Add("style", "display: none;");
            this.liSelectOption.Attributes.Add("style", "display: none;");
            this.olMyAddress.Attributes.Add("style", "display: none;");
            this.olShipToMyClient.Attributes.Add("style", "display: none;");
            this.olDeliveryInformation.Attributes.Add("style", "display: none;");

            if (this.rbShipToMe.Checked == true)
            {
                this.dvCourier.Attributes.Add("style", "display: block;");
                this.liSelectOption.Attributes.Add("style", "display: block;");
                this.olMyAddress.Attributes.Add("style", "display: block;");
            }
            if (this.rbShipToMyClient.Checked == true)
            {
                this.dvCourier.Attributes.Add("style", "display: block;");
                this.liSelectOption.Attributes.Add("style", "display: block;");
                this.olShipToMyClient.Attributes.Add("style", "display: block;");
            }
            if (this.rbShipToNewClient.Checked == true)
            {
                this.dvCourier.Attributes.Add("style", "display: block;");
                this.liSelectOption.Attributes.Add("style", "display: block;");
                this.olDeliveryInformation.Attributes.Add("style", "display: block;");
            }
        }

        /*private void AutoGeneratedNumber()
        {
            try
            {
                List<AutoOrderNumberBO> lstAutoOrderNo = new List<AutoOrderNumberBO>();
                int orderNumber = 0;

                string lstOrder = (new OrderBO()).SearchObjects().Select(m => m.OrderNumber).Max();
                if (!string.IsNullOrEmpty(lstOrder))
                {
                    orderNumber = int.Parse(lstOrder.ToString()) + 1;
                    lstAutoOrderNo = (from o in (new AutoOrderNumberBO()).SearchObjects() select o).ToList();

                    if (lstAutoOrderNo.Count == 0)
                    {
                        ViewState["OrderNumber"] = orderNumber.ToString();
                    }
                    else
                    {
                        lstAutoOrderNo = (from o in lstAutoOrderNo.OrderBy(o => o.CreatedDate) select o).ToList();
                        if (lstAutoOrderNo[0].CreatedDate < DateTime.Now.AddHours(-72))
                        {
                            ViewState["OrderNumber"] = lstAutoOrderNo[0].Name;
                        }
                        else
                        {
                            lstAutoOrderNo = (from o in (new AutoOrderNumberBO()).SearchObjects().OrderByDescending(o => o.CreatedDate).Take(1)
                                              select o).ToList();
                            orderNumber = int.Parse(lstAutoOrderNo[0].Name) + 1;
                            ViewState["OrderNumber"] = orderNumber.ToString();
                        }
                    }
                }
                else
                {
                    lstAutoOrderNo = (from o in (new AutoOrderNumberBO()).SearchObjects() select o).ToList();

                    if (lstAutoOrderNo.Count == 0)
                    {
                        ViewState["OrderNumber"] = "1";
                    }
                    else
                    {
                        lstAutoOrderNo = (from o in lstAutoOrderNo.OrderBy(o => o.CreatedDate) select o).ToList();
                        if (lstAutoOrderNo[0].CreatedDate < DateTime.Now.AddHours(-72))
                        {
                            ViewState["OrderNumber"] = lstAutoOrderNo[0].Name;
                        }
                        else
                        {
                            lstAutoOrderNo = (from o in (new AutoOrderNumberBO()).SearchObjects().OrderByDescending(o => o.CreatedDate).Take(1)
                                              select o).ToList();
                            orderNumber = int.Parse(lstAutoOrderNo[0].Name) + 1;
                            ViewState["OrderNumber"] = orderNumber.ToString();
                        }

                    }
                }

                lstAutoOrderNo = (from o in lstAutoOrderNo.Where(o => o.Name == ViewState["OrderNumber"].ToString()) select o).ToList();

                if (lstAutoOrderNo.Count > 0)
                {
                    foreach (AutoOrderNumberBO number in lstAutoOrderNo)
                    {
                        AutoOrderNumberBO objAutoOrderNo = new AutoOrderNumberBO(this.ObjContext);
                        objAutoOrderNo.ID = number.ID;
                        objAutoOrderNo.GetObject();

                        using (TransactionScope ts = new TransactionScope())
                        {
                            objAutoOrderNo.Name = ViewState["OrderNumber"].ToString();
                            objAutoOrderNo.CreatedDate = DateTime.Now;

                            this.ObjContext.SaveChanges();
                            ts.Complete();
                        }
                    }
                }
                else
                {
                    using (TransactionScope ts = new TransactionScope())
                    {
                        AutoOrderNumberBO objAutoOrderNo = new AutoOrderNumberBO(this.ObjContext);
                        objAutoOrderNo.Name = ViewState["OrderNumber"].ToString();
                        objAutoOrderNo.CreatedDate = DateTime.Now;

                        objAutoOrderNo.Add();

                        this.ObjContext.SaveChanges();
                        ts.Complete();
                    }
                }


                this.txtRefference.Text = ViewState["OrderNumber"].ToString();
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while generation auto number in order", ex);
            }
        }*/

        #endregion
    }
}