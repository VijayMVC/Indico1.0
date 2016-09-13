using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Transactions;
using System.IO;

using Indico.BusinessObjects;
using Indico.Common;

namespace Indico
{
    public partial class AddEditFabricCode : IndicoPage
    {
        #region Fields

        private int urlQueryID = -1;

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

        protected void btnSaveChanges_ServerClick(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                if (!string.IsNullOrEmpty(this.txtFabricCode.Text))
                {
                    List<FabricCodeBO> lstFabricCodes = (List<FabricCodeBO>)Session["ListFabricCodes"];
                    lstFabricCodes = lstFabricCodes.Where(m => m.Code == this.txtFabricCode.Text).ToList();

                    if (lstFabricCodes.Any())
                    {
                        if (this.QueryID == 0 || !lstFabricCodes.Select(m => m.ID).Contains(this.QueryID))
                        {
                            CustomValidator cv = new CustomValidator();
                            cv.IsValid = false;
                            cv.ValidationGroup = "valCombined";
                            cv.ErrorMessage = "Fabric Code exists in the system.";
                            Page.Validators.Add(cv);
                        }
                    }
                }

                if (Page.IsValid)
                {
                    this.ProcessForm(this.QueryID, false);
                    Response.Redirect("~/ViewFabricCodes.aspx?type=0");
                }
            }
        }

        protected void ddlAddFabrics_SelectedIndexChanged(object sender, EventArgs e)
        {
            ViewState["IsPageValidCombined"] = false;

            int fabric = int.Parse(((System.Web.UI.WebControls.ListControl)(sender)).SelectedValue);
            int fabricType = int.Parse(ddlFabricCodeType.SelectedValue);

            CustomValidator cv = null;

            if (ddlFabricCodeType.SelectedIndex < 1)
            {
                cv = new CustomValidator();
                cv.IsValid = false;
                cv.ValidationGroup = "valCombined";
                cv.ErrorMessage = "Fabric Type is required.";
                Page.Validators.Add(cv);
            }
            else if (fabric > 0)
            {
                List<KeyValuePair<int, KeyValuePair<int, string>>> lstFabrics = (List<KeyValuePair<int, KeyValuePair<int, string>>>)Session["CombinedFabrics"];

                if (fabricType == 0 && lstFabrics.Where(o => o.Key == 0).Any())
                {
                    cv = new CustomValidator();
                    cv.IsValid = false;
                    cv.ValidationGroup = "valCombined";
                    cv.ErrorMessage = "Main Fabric alredy exists in the list.";
                    Page.Validators.Add(cv);
                }
                else if (lstFabrics.Where(o => o.Value.Key == fabric).Any())
                {
                    cv = new CustomValidator();
                    cv.IsValid = false;
                    cv.ValidationGroup = "valCombined";
                    cv.ErrorMessage = "This Fabric alredy exists in the list.";
                    Page.Validators.Add(cv);
                }
                else
                {
                    this.PopulateFabricDataGrid(fabric, fabricType);
                }
            }
            this.ddlAddFabrics.SelectedIndex = 0;
        }

        protected void ddlFabricCodeType_SelectedIndexChanged(object sender, EventArgs e)
        {
            int type = int.Parse(((System.Web.UI.WebControls.ListControl)(sender)).SelectedValue);

            if (type == (int)FabricType.Lining)
            {
                PopulateFilteredFabrics(true);
            }
            else
            {
                PopulateFilteredFabrics(false);
            }
        }

        protected void dgvAddEditFabrics_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            DataGridItem item = e.Item;

            if (item.ItemIndex > -1 && item.DataItem is KeyValuePair<int, KeyValuePair<int, string>>) // KeyValuePair<Tuple<int, int>, int>)
            {
                KeyValuePair<int, KeyValuePair<int, string>> kv = (KeyValuePair<int, KeyValuePair<int, string>>)item.DataItem;

                Literal litID = (Literal)item.FindControl("litID");
                Literal litFabricTypeID = (Literal)item.FindControl("litFabricTypeID");
                Literal litFabricType = (Literal)item.FindControl("litFabricType");
                Literal litCode = (Literal)item.FindControl("litCode");
                Literal litFabricNickName = (Literal)item.FindControl("litFabricNickName");
                Literal litFabricSupplier = (Literal)item.FindControl("litFabricSupplier");
                TextBox txtWhere = (TextBox)item.FindControl("txtWhere");

                litFabricTypeID.Text = kv.Key.ToString();

                int value = kv.Key;
                FabricType type = (FabricType)value;
                litFabricType.Text = type.ToString();

                FabricCodeBO objFC = new FabricCodeBO();
                objFC.ID = kv.Value.Key;
                objFC.GetObject();

                txtWhere.Text = kv.Value.Value;

                //litVFID.Text = "0";
                litID.Text = objFC.ID.ToString();
                litCode.Text = objFC.Code;
                litFabricNickName.Text = objFC.NickName;
                litFabricSupplier.Text = (objFC.Supplier.HasValue && objFC.Supplier.Value > 0) ? objFC.objSupplier.Name : string.Empty;
                //    ddlfabricCodeType.Items.FindByValue(kv.Key.Item2.ToString()).Selected = true;
                //}
            }
        }

        protected void dgvAddEditFabrics_ItemCommand(object source, DataGridCommandEventArgs e)
        {
            string commandName = e.CommandName;

            switch (commandName)
            {
                case "Delete":
                    Literal litID = (Literal)e.Item.FindControl("litID");
                    int fabric = int.Parse(litID.Text.ToString());

                    Literal litFabricTypeID = (Literal)e.Item.FindControl("litFabricTypeID");
                    int fabricType = int.Parse(litFabricTypeID.Text);

                    this.PopulateFabricDataGrid(fabric, fabricType, true);

                    break;
                default:
                    break;
            }
        }

        #endregion

        #region Methods

        /// <summary>
        /// Populate the controls.
        /// </summary>
        private void PopulateControls()
        {
            //Header Text
            this.litHeaderText.Text = ((this.QueryID > 0) ? "Edit " : "New ") + this.ActivePage.Heading;
            Session["CombinedFabrics"] = new List<KeyValuePair<int, KeyValuePair<int, string>>>();

            //Fabric Types
            ddlFabricCodeType.Items.Clear();
            ddlFabricCodeType.Items.Add(new ListItem("Select a Type", "-1"));
            int fabricCodeType = 0;
            foreach (FabricType type in Enum.GetValues(typeof(FabricType)))
            {
                ddlFabricCodeType.Items.Add(new ListItem(type.ToString(), fabricCodeType++.ToString()));
            }

            FabricCodeBO objFabric = new FabricCodeBO();
            if (this.QueryID < 1)
                objFabric.IsActive = true;
            List<FabricCodeBO> lstFabricCodes = objFabric.SearchObjects();
            Session["ListFabricCodes"] = lstFabricCodes;

            this.PopulateFabricDataGrid(0, 0);
        }

        /// <summary>
        /// Process the page data.
        /// </summary>
        private void ProcessForm(int fabricID, bool isDelete)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    FabricCodeBO objFabricCode = new FabricCodeBO(this.ObjContext);
                    if (fabricID > 0)
                    {
                        objFabricCode.ID = fabricID;
                        objFabricCode.GetObject();
                    }

                    if (isDelete)
                    {
                        objFabricCode.Delete();
                    }
                    else
                    {
                        objFabricCode.Code = this.txtFabricCode.Text;
                        objFabricCode.Name = this.txtCombinedName.Text;
                        objFabricCode.NickName = (!String.IsNullOrEmpty(this.txtCombinedNickName.Text)) ? this.txtCombinedNickName.Text : string.Empty;
                        objFabricCode.IsActive = (this.chkCombinedIsActive.Checked) ? true : false;

                        objFabricCode.IsLiningFabric = false;
                        objFabricCode.IsPure = false;
                        objFabricCode.Country = 14;

                        if (fabricID == 0)
                        {
                            objFabricCode.Add();
                        }
                    }

                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }
            }
            catch (Exception ex)
            {
                // Log the error
                IndicoLogging.log.Error("Error occured while Saving Fabric", ex);
            }
        }

        private void PopulateFilteredFabrics(bool isLining)
        {
            FabricCodeBO objFabric = new FabricCodeBO();
            objFabric.IsActive = true;
            objFabric.IsPure = true;
            objFabric.IsLiningFabric = isLining;

            Dictionary<int, string> filteredfabrics = objFabric.SearchObjects().AsQueryable().OrderBy(o => o.Name).ToList().Select(o => new { Key = o.ID, Value = (o.Code + " - " + o.NickName) }).ToDictionary(o => o.Key, o => o.Value);
            Dictionary<int, string> fdicFabrics = new Dictionary<int, string>();

            fdicFabrics.Add(0, "Please select or type...");
            foreach (KeyValuePair<int, string> item in filteredfabrics)
            {
                fdicFabrics.Add(item.Key, item.Value);
            }

            this.ddlAddFabrics.DataSource = fdicFabrics;
            this.ddlAddFabrics.DataTextField = "Value";
            this.ddlAddFabrics.DataValueField = "Key";
            this.ddlAddFabrics.DataBind();
        }

        private void PopulateFabricDataGrid(int fabricID, int typeID, bool isDeleted = false)
        {
            List<KeyValuePair<int, KeyValuePair<int, string>>> fcIds = this.GetFilteredFabricData(fabricID, typeID, isDeleted);

            this.dgvAddEditFabrics.DataSource = fcIds;
            this.dgvAddEditFabrics.DataBind();

            this.dgvAddEditFabrics.Visible = (this.dgvAddEditFabrics.Items.Count > 0);
            this.dvEmptyFabrics.Visible = !this.dgvAddEditFabrics.Visible;

            PopulateFabricName();
        }

        private void PopulateFabricName()
        {
            string mainFabName = string.Empty;
            string secondaryFabName = string.Empty;
            string liningFabName = string.Empty;

            string combinedName = string.Empty;
            string combinedNickName = string.Empty;

            foreach (DataGridItem item in this.dgvAddEditFabrics.Items)
            {
                Literal litID = (Literal)item.FindControl("litID");
                Literal litFabricTypeID = (Literal)item.FindControl("litFabricTypeID");

                FabricCodeBO objFab = new FabricCodeBO();
                objFab.ID = int.Parse(litID.Text);
                objFab.GetObject();

                if (int.Parse(litFabricTypeID.Text) == 0)
                {
                    mainFabName = objFab.Code;
                }
                else if (objFab.IsLiningFabric)
                {
                    liningFabName += objFab.Code + "+";
                }
                else
                {
                    secondaryFabName += objFab.Code + "+";
                }

                combinedName += objFab.Name + " + ";
                combinedNickName += objFab.NickName + " + ";
            }

            liningFabName = string.IsNullOrEmpty(liningFabName) ? "" : "+" + liningFabName.Remove(liningFabName.Length - 1, 1);
            secondaryFabName = string.IsNullOrEmpty(secondaryFabName) ? "" : "+" + secondaryFabName.Remove(secondaryFabName.Length - 1, 1);

            combinedName = string.IsNullOrEmpty(combinedName) ? "" : combinedName.Remove(combinedName.Length - 3, 3);
            combinedNickName = string.IsNullOrEmpty(combinedNickName) ? "" : combinedNickName.Remove(combinedNickName.Length - 3, 3);

            string selectedFabric = mainFabName + secondaryFabName + liningFabName;
            this.txtFabricCode.Text = selectedFabric;
            this.txtCombinedName.Text = combinedName;
            this.txtCombinedNickName.Text = combinedNickName;

            List<FabricCodeBO> lstFabricCodes = (List<FabricCodeBO>)Session["ListFabricCodes"];

            if (!string.IsNullOrEmpty(selectedFabric) && lstFabricCodes != null)
            {
                try
                {
                    lstFabricCodes = lstFabricCodes.Where(m => m.Code == selectedFabric).ToList();

                    if (lstFabricCodes.Any())
                    {
                        if (this.QueryID == 0 || (this.QueryID > 0 && !lstFabricCodes.Select(m => m.ID).Contains(this.QueryID)))
                        {
                            CustomValidator cv = new CustomValidator();
                            cv.IsValid = false;
                            cv.ValidationGroup = "valCombined";
                            cv.ErrorMessage = "Fabric Code exists in the system.";
                            Page.Validators.Add(cv);
                        }
                    }
                }
                catch (Exception ex)
                {
                    //lblVLFabricErrorText.Text = "The fabric combination selected, does not exist in Indiman Price List.  Please contact Indiman administrator to include in fabric combination list.";
                }
            }
        }

        private List<KeyValuePair<int, KeyValuePair<int, string>>> GetFilteredFabricData(int fabricID, int typeID, bool isDeleted)
        {
            List<KeyValuePair<int, KeyValuePair<int, string>>> lst = new List<KeyValuePair<int, KeyValuePair<int, string>>>();

            foreach (DataGridItem item in this.dgvAddEditFabrics.Items)
            {
                Literal litID = (Literal)item.FindControl("litID");
                Literal litFabricTypeID = (Literal)item.FindControl("litFabricTypeID");
                Literal litFabricType = (Literal)item.FindControl("litFabricType");
                TextBox txtWhere = (TextBox)item.FindControl("txtWhere");

                lst.Add(new KeyValuePair<int, KeyValuePair<int, string>>(int.Parse(litFabricTypeID.Text), new KeyValuePair<int, string>(int.Parse(litID.Text), txtWhere.Text)));
            }

            if (fabricID > 0) // Add, Delete
            {
                if (isDeleted)
                {
                    KeyValuePair<int, KeyValuePair<int, string>> removeFabric = lst.Where(m => m.Key == typeID && m.Value.Key == fabricID).SingleOrDefault();
                    lst.Remove(removeFabric);
                }
                else
                {
                    lst.Add(new KeyValuePair<int, KeyValuePair<int, string>>(typeID, new KeyValuePair<int, string>(fabricID, "")));
                }
            }
            else // Page edit mode to load all data 
            {
                if (this.QueryID > 0)
                {
                    FabricCodeBO objFabric = new FabricCodeBO();
                    objFabric.ID = QueryID;
                    objFabric.GetObject();

                    this.txtCombinedName.Text = objFabric.Name;
                    this.txtCombinedNickName.Text = objFabric.NickName;
                    this.chkCombinedIsActive.Checked = objFabric.IsActive;

                    try
                    {
                        string[] codes = objFabric.Code.Split('+');
                        //string[] wheres = string.IsNullOrEmpty(objVL.Where) ? new string[0] : objVL.Where.Split(',');

                        List<KeyValuePair<int, string>> lstWheres = new List<KeyValuePair<int, string>>();

                        //foreach (string whereText in wheres)
                        //{
                        //    lstWheres.Add(new KeyValuePair<int, string>(int.Parse(whereText.Split('-')[0]), whereText.Split('-')[1]));
                        //}

                        List<FabricCodeBO> lstFabricCodes = (List<FabricCodeBO>)Session["ListFabricCodes"];

                        int fabricPosition = 0;

                        foreach (string code in codes)
                        {
                            FabricCodeBO objFabCode = lstFabricCodes.Where(m => m.Code == code).Single();
                            string whereText = lstWheres.Where(m => m.Key == objFabCode.ID).SingleOrDefault().Value;

                            if (++fabricPosition == 1)
                            {
                                lst.Add(new KeyValuePair<int, KeyValuePair<int, string>>((int)FabricType.Main, new KeyValuePair<int, string>(objFabCode.ID, whereText)));
                            }
                            else if (objFabCode.IsLiningFabric)
                            {
                                lst.Add(new KeyValuePair<int, KeyValuePair<int, string>>((int)FabricType.Lining, new KeyValuePair<int, string>(objFabCode.ID, whereText)));
                            }
                            else
                            {
                                lst.Add(new KeyValuePair<int, KeyValuePair<int, string>>((int)FabricType.Secondary, new KeyValuePair<int, string>(objFabCode.ID, whereText)));
                            }
                        }
                    }
                    catch (Exception ex)
                    {

                    }
                }
            }

            Session["CombinedFabrics"] = lst;
            return lst;
        }

        #endregion
    }
}