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

namespace Indico
{
    public partial class ViewEmbroideries : IndicoPage
    {
        #region Fields

        #endregion

        #region Properties

        private string SortExpression
        {
            get
            {
                string sort = (string)ViewState["AgeGroupsSortExpression"];
                if (string.IsNullOrEmpty(sort))
                {
                    sort = "JobName";
                }
                return sort;
            }
            set
            {
                ViewState["AgeGroupsSortExpression"] = value;
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

        protected void RadGridEmbroideries_ItemDataBound(object sender, GridItemEventArgs e)
        {
            if (e.Item is GridDataItem)
            {
                var item = e.Item as GridDataItem;

                if ((item.ItemIndex > -1 && item.DataItem is EmbroideryDetailsViewBO))
                {
                    EmbroideryDetailsViewBO objEmbroideryDetails = (EmbroideryDetailsViewBO)item.DataItem;

                    HyperLink linkEdit = (HyperLink)item.FindControl("linkEdit");
                    linkEdit.NavigateUrl = "/AddEditEmbroidery.aspx?id=" + objEmbroideryDetails.Embroidery.ToString();

                    HyperLink linkDelete = (HyperLink)item.FindControl("linkDelete");
                    linkDelete.Attributes.Add("qid", objEmbroideryDetails.Embroidery.ToString());
                }
            }
        }

        protected void RadGridEmbroideries_SortCommand(object sender, GridSortCommandEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridEmbroideries_ItemCommand(object sender, GridCommandEventArgs e)
        {
            //if (e.CommandName == RadGrid.FilterCommandName)
            //{
                this.ReBindGrid();
            //}
        }

        protected void RadGridEmbroideries_PageIndexChanged(object sender, GridPageChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridEmbroideries_GroupsChanging(object sender, GridGroupsChangingEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void HeaderContextMenu_ItemCLick(object sender, RadMenuEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void RadGridEmbroideries_PageSizeChanged(object sender, GridPageSizeChangedEventArgs e)
        {
            this.ReBindGrid();
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            ViewState["IsPageValied"] = true;
            this.PopulateDataGrid();
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            int id = int.Parse(this.hdnSelectedID.Value);
            string imagePath = string.Empty;

            if (id > 0)
            {
                try
                {
                    using (TransactionScope ts = new TransactionScope())
                    {
                        EmbroideryBO objEmbroider = new EmbroideryBO(this.ObjContext);
                        objEmbroider.ID = id;
                        objEmbroider.GetObject();

                        foreach (EmbroideryDetailsBO embDetail in objEmbroider.EmbroideryDetailssWhereThisIsEmbroidery)
                        {
                            // delete Image
                            EmbroideryDetailsBO objEmbroiderDetails = new EmbroideryDetailsBO(this.ObjContext);
                            objEmbroiderDetails.ID = embDetail.ID;
                            objEmbroiderDetails.GetObject();

                            foreach (EmbroideryImageBO image in objEmbroiderDetails.EmbroideryImagesWhereThisIsEmbroideryDetails)
                            {
                                imagePath = IndicoConfiguration.AppConfiguration.DataFolderName + "/EmbroideryImages/" + "/" + image.EmbroideryDetails.ToString() + "/" + image.Filename + image.Extension;

                                if (File.Exists(Server.MapPath(imagePath)))
                                {
                                    File.Delete(Server.MapPath(imagePath));
                                }

                                EmbroideryImageBO objEmbroideryImage = new EmbroideryImageBO(this.ObjContext);
                                objEmbroideryImage.ID = image.ID;
                                objEmbroideryImage.GetObject();

                                objEmbroideryImage.Delete();
                            }

                            objEmbroiderDetails.Delete();
                        }

                        objEmbroider.Delete();

                        this.ObjContext.SaveChanges();
                        ts.Complete();
                    }
                }
                catch (Exception ex)
                {
                    IndicoLogging.log.Error("Error occured while deleting From ViewEmbriderDetails.aspx", ex);
                }
            }
            this.PopulateDataGrid();

        }

        #endregion

        #region Methods

        /// <summary>
        /// Populate the controls.
        /// </summary>
        private void PopulateControls()
        {
            this.litHeaderText.Text = this.ActivePage.Heading;

            // Populate Grid
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
                EmbroideryDetailsViewBO objEmbroidery = new EmbroideryDetailsViewBO();

                List<EmbroideryDetailsViewBO> lstEmbroideries = new List<EmbroideryDetailsViewBO>();
                if ((searchText != string.Empty) && (searchText != "search"))
                {
                    lstEmbroideries = (from o in objEmbroidery.SearchObjects().AsQueryable().OrderBy(SortExpression).ToList()
                                       where o.JobName.ToLower().Contains(searchText) ||
                                       o.Distributor.ToLower().Contains(searchText) ||
                                       o.Coordinator.ToLower().Contains(searchText) ||
                                       o.Client.ToLower().Contains(searchText)
                                       orderby o.Embroidery
                                       select o).ToList();
                }
                else
                {
                    lstEmbroideries = objEmbroidery.SearchObjects().AsQueryable().OrderBy(o => o.Embroidery).ToList();
                }

                if (lstEmbroideries.Count > 0)
                {
                    this.RadGridEmbroideries.AllowPaging = (lstEmbroideries.Count > this.RadGridEmbroideries.PageSize);
                    this.RadGridEmbroideries.DataSource = lstEmbroideries;
                    Session["EmbroideryDetailsView"] = lstEmbroideries;
                    this.RadGridEmbroideries.DataBind();

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
                }

                this.RadGridEmbroideries.Visible = (lstEmbroideries.Count > 0);
            }
        }

        private void ReBindGrid()
        {
            if (Session["EmbroideryDetailsView"] != null)
            {
                RadGridEmbroideries.DataSource = (List<EmbroideryDetailsViewBO>)Session["EmbroideryDetailsView"];
                RadGridEmbroideries.DataBind();
            }
        }

        #endregion
                
    }
}