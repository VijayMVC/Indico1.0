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
    public partial class ViewMYOBCardFiles : IndicoPage
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

        protected void RadGridMYOBCardFile_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridMYOBCardFile_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridMYOBCardFile_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if (item.ItemIndex > -1 && item.DataItem is MYOBCardFileBO)
                {
                    MYOBCardFileBO objMYOBCardFile = (MYOBCardFileBO)item.DataItem;

                    HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
                    linkEdit.Attributes.Add("qid", objMYOBCardFile.ID.ToString());

                    HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                    linkDelete.Attributes.Add("qid", objMYOBCardFile.ID.ToString());
                    linkDelete.Visible = !(objMYOBCardFile.OrdersWhereThisIsMYOBCardFile.Any());
                }
            }
        }

        protected void RadGridMYOBCardFile_ItemCommand(object sender, GridCommandEventArgs e)
        {
            if (e.CommandName == RadGrid.FilterCommandName)
            {
                this.ReBindGrid();
            }
        }

        protected void RadGridMYOBCardFile_SortCommand(object sender, GridSortCommandEventArgs e)
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
                int myobCardFileID = int.Parse(this.hdnSelectedMYOBCardFileID.Value.Trim());

                if (Page.IsValid)
                {
                    this.ProcessForm(myobCardFileID, false);

                    Response.Redirect("/ViewMYOBCardFiles.aspx");
                }

                ViewState["IsPageValid"] = (Page.IsValid);
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int myobCardFileID = int.Parse(this.hdnSelectedMYOBCardFileID.Value.Trim());

            if (!Page.IsValid)
            {
                this.ProcessForm(myobCardFileID, true);

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
                int myobCardFileID = int.Parse(this.hdnSelectedMYOBCardFileID.Value.Trim());
                ReturnIntViewBO objReturnInt = new ReturnIntViewBO();
                objReturnInt = SettingsBO.ValidateField(myobCardFileID, "MYOBCardFile", "Name", this.txtMYOBCardFileName.Text);
                args.IsValid = objReturnInt.RetVal == 1;
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while cvTxtName_ServerValidate on ViewMYOBCardFiles.aspx", ex);
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

            lblPopupHeaderText.Text = "New MYOB Card File";
            ViewState["IsPageValid"] = true;
            Session["MYOBCardFileDetails"] = null;

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
                MYOBCardFileBO objMYOBCardFile = new MYOBCardFileBO();
                List<MYOBCardFileBO> lstMYOBCardFiles;

                if ((searchText != string.Empty) && (searchText != "search"))
                {
                    lstMYOBCardFiles = (from o in objMYOBCardFile.SearchObjects().ToList()
                                        where o.Name.ToLower().Contains(searchText) ||
                                        (o.Description != null ? o.Description.ToLower().Contains(searchText) : false)
                                        select o).ToList();
                }
                else
                {
                    lstMYOBCardFiles = objMYOBCardFile.SearchObjects().ToList();
                }

                if (lstMYOBCardFiles.Count > 0)
                {
                    this.RadGridMYOBCardFile.AllowPaging = (lstMYOBCardFiles.Count > this.RadGridMYOBCardFile.PageSize);
                    this.RadGridMYOBCardFile.DataSource = lstMYOBCardFiles;
                    this.RadGridMYOBCardFile.DataBind();
                    Session["MYOBCardFileDetails"] = lstMYOBCardFiles;

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
                    this.btnAddMYOB.Visible = false;
                }

                this.RadGridMYOBCardFile.Visible = (lstMYOBCardFiles.Count > 0);
            }
        }

        private void ProcessForm(int myobId, bool isDelete)
        {
            try
            {
                using (TransactionScope ts = new TransactionScope())
                {
                    MYOBCardFileBO objMYOB = new MYOBCardFileBO(this.ObjContext);
                    if (myobId > 0)
                    {
                        objMYOB.ID = myobId;
                        objMYOB.GetObject();
                        objMYOB.Name = this.txtMYOBCardFileName.Text;
                        objMYOB.Description = this.txtDescription.Text;

                        if (isDelete)
                        {
                            objMYOB.Delete();
                        }
                    }
                    else
                    {
                        objMYOB.Name = this.txtMYOBCardFileName.Text;
                        objMYOB.Description = this.txtDescription.Text;
                        objMYOB.Add();
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
            if (Session["MYOBCardFileDetails"] != null)
            {
                RadGridMYOBCardFile.DataSource = (List<MYOBCardFileBO>)Session["MYOBCardFileDetails"];
                RadGridMYOBCardFile.DataBind();
            }
        }

        #endregion
    }
}