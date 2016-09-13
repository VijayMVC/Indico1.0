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

namespace Indico
{
    public partial class ViewSettings : IndicoPage
    {
        #region Fields

        #endregion

        #region Properties

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

        protected void RadGridSettings_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridSettings_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridSettings_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if (item.ItemIndex > -1 && item.DataItem is SettingsBO)
                {
                    SettingsBO objSetting = (SettingsBO)item.DataItem;

                    HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
                    linkEdit.Attributes.Add("qid", objSetting.ID.ToString());

                    HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                    linkDelete.Visible = false;
                    linkDelete.Attributes.Add("qid", objSetting.ID.ToString());
                }
            }
        }

        protected void RadGridSettings_ItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                this.ReBindGrid();
            }
        }

        protected void RadGridSettings_SortCommand(object sender, GridSortCommandEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void HeaderContextMenu_ItemCLick(object sender, RadMenuEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            ViewState["IsPageValied"] = true;
            this.PopulateDataGrid();
        }

        protected void btnSaveChanges_Click(object sender, EventArgs e)
        {
            if (this.IsNotRefresh)
            {
                int SettingID = int.Parse(this.hdnSelectedSettingID.Value.Trim());

                if (Page.IsValid)
                {
                    this.ProcessForm(SettingID, false);

                    Response.Redirect("/ViewSettings.aspx");
                }

                ViewState["IsPageValid"] = (Page.IsValid);
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int settingID = int.Parse(this.hdnSelectedSettingID.Value.Trim());

            if (!Page.IsValid)
            {
                this.ProcessForm(settingID, true);

                this.PopulateDataGrid();
            }

            ViewState["IsPageValid"] = (Page.IsValid);
            ViewState["IsPageValid"] = true;
            this.validationSummary.Visible = !(Page.IsValid);
        }
        
        protected void cvTxtName_ServerValidate(object source, ServerValidateEventArgs args)
        {
            try
            {
                int SettingID = int.Parse(this.hdnSelectedSettingID.Value.Trim());
                ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                objReturnInt = SettingsBO.ValidateField(SettingID, "Settings", "Name", this.txtSettingName.Text);
                args.IsValid = objReturnInt.RetVal == 1;
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while cvTxtName_ServerValidate on ViewSettings.aspx", ex);
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

            lblPopupHeaderText.Text = "New Setting";
            ViewState["IsPageValid"] = true;
            Session["SettingsDetails"] = null;

            this.PopulateDataGrid();

        }

        private void PopulateDataGrid()
        {
            {
                // Hide Controls
                this.dvEmptyContent.Visible = false;
                this.dvDataContent.Visible = false;
                this.dvNoSearchResult.Visible = false;

                // Search text
                string searchText = this.txtSearch.Text.ToLower().Trim();

                // Populate Items
                SettingsBO objSetting = new SettingsBO();
                List<SettingsBO> lstSettings;

                if ((searchText != string.Empty) && (searchText != "search"))
                {
                    lstSettings = (from o in objSetting.SearchObjects().ToList()
                                   where o.Name.ToLower().Contains(searchText)
                                   select o).ToList();
                }
                else
                {
                    lstSettings = objSetting.SearchObjects().ToList();
                }

                if (lstSettings.Count > 0)
                {
                    this.RadGridSettings.AllowPaging = (lstSettings.Count > this.RadGridSettings.PageSize);
                    this.RadGridSettings.DataSource = lstSettings;
                    this.RadGridSettings.DataBind();
                    Session["SettingsDetails"] = lstSettings;

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
                    this.btnAddSetting.Visible = false;
                }

                this.RadGridSettings.Visible = (lstSettings.Count > 0);
            }
        }

        private void ProcessForm(int settingId, bool isDelete)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    SettingsBO objAgeGroup = new SettingsBO(this.ObjContext);
                    if (settingId > 0)
                    {
                        objAgeGroup.ID = settingId;
                        objAgeGroup.GetObject();
                        objAgeGroup.Name = this.txtSettingName.Text;
                        objAgeGroup.Value = this.txtValue.Text;

                        if (isDelete)
                        {
                            objAgeGroup.Delete();
                        }
                    }
                    else
                    {
                        objAgeGroup.Name = this.txtSettingName.Text;
                        objAgeGroup.Value = this.txtValue.Text;
                        objAgeGroup.Add();
                    }

                    this.ObjContext.SaveChanges();
                    ts.Complete();
                }
            }
            catch (Exception ex)
            {
                //throw ex;
            }
        }

        private void ReBindGrid()
        {
            if (Session["SettingsDetails"] != null)
            {
                RadGridSettings.DataSource = (List<SettingsBO>)Session["SettingsDetails"];
                RadGridSettings.DataBind();
            }
        }

        #endregion
    }
}