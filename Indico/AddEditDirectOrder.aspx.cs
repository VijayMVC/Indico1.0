using Indico.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Indico
{
    public partial class AddEditDirectOrder : IndicoPage
    {
        #region Fields

        decimal footerQty = 0;
        decimal footerValue = 0;

        #endregion

        #region Properties

        //protected int ItemCount
        //{
        //    get
        //    {
        //        int c = 1;
        //        try
        //        {
        //            if (Session["ItemCount"] != null)
        //                c = Convert.ToInt32(Session["ItemCount"]);
        //        }
        //        catch (Exception) { }

        //        Session["ItemCount"] = c;

        //        return c;
        //    }
        //    set
        //    {
        //        Session["ItemCount"] = value;
        //    }
        //}

        private List<OrderItem> CurrentItems
        {
            get
            {
                if (Session["CurrentItems"] == null)
                {
                    List<OrderItem> lstTemp = new List<OrderItem>();
                    lstTemp.Add(new OrderItem(0));
                    Session["CurrentItems"] = lstTemp; 
                }

                return (List<OrderItem>)Session["CurrentItems"];
            }
            set
            {
                Session["CurrentItems"] = value;
            }
        }

        #endregion

        #region Constructors

        #endregion

        #region Events

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!this.IsPostBack)
            {
                PopulateControls();
            }
        }

        protected void rptItem_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RepeaterItem item = e.Item;
            if (item.ItemIndex > -1 && item.DataItem is OrderItem)
            {
                OrderItem objItem = (OrderItem)item.DataItem;
                DataGrid dgItem = (DataGrid)item.FindControl("dgItem");
                Literal litItemNumber = (Literal)item.FindControl("litItemNumber");
                HiddenField hdnItemNumber = (HiddenField)item.FindControl("hdnItemNumber");
                LinkButton lnkRemove = (LinkButton)item.FindControl("lnkRemove");

                this.footerQty = 0;
                this.footerValue = 0;
                litItemNumber.Text = "Item " + objItem.ItemNumber;
                //                lnkRemove.Visible = objItem.ItemNumber > 1;
                hdnItemNumber.Value = objItem.ItemNumber.ToString();
                dgItem.DataSource = objItem.ListItemRow;
                dgItem.DataBind();
            }
        }

        protected void rptItem_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Remove")
            {
                HiddenField hdnItemNumber = (HiddenField)e.Item.FindControl("hdnItemNumber");
                this.CurrentItems.RemoveAll(m => m.ItemNumber == int.Parse(hdnItemNumber.Value));
                this.ReBindRepeater();
            }
        }

        protected void dgItem_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            DataGridItem item = e.Item;

            if (item.ItemIndex > -1 && item.DataItem is OrderItemRow)
            {
                OrderItemRow objItemRow = (OrderItemRow)item.DataItem;

                Literal litAgeGroup = (Literal)item.FindControl("litAgeGroup");
                Literal litSize = (Literal)item.FindControl("litSize");
                Literal litQuantity = (Literal)item.FindControl("litQuantity");
                Literal litPrice = (Literal)item.FindControl("litPrice");
                Literal litValue = (Literal)item.FindControl("litValue");

                litAgeGroup.Text = objItemRow.AgeGroup.ToString();
                litSize.Text = objItemRow.Size.ToString();
                litQuantity.Text = objItemRow.Qty.ToString();
                litPrice.Text = objItemRow.Price.ToString();
                litValue.Text = objItemRow.Value.ToString();

                this.footerQty += objItemRow.Qty;
                this.footerValue += objItemRow.Value;
            }
            if (item.ItemType == ListItemType.Footer)
            {
                Literal litFooterQuantity = (Literal)item.FindControl("litFooterQuantity");
                Literal litFooterValue = (Literal)item.FindControl("litFooterValue");

                litFooterQuantity.Text = footerQty.ToString();
                litFooterValue.Text = footerValue.ToString();

            }
        }

        protected void btnAddItem_Click(object sender, EventArgs e)
        {
            int currentItem = 0;
            if (this.CurrentItems.Any())
                currentItem = this.CurrentItems.Select(m => m.ItemNumber).Max();

            this.CurrentItems.Add(new OrderItem(currentItem));

            ReBindRepeater();
        }

        #endregion

        #region Methods

        private void PopulateControls()
        {
            this.CurrentItems = null;
            this.ReBindRepeater();
        }

        private void ProcessForm()
        {

        }

        private void ReBindRepeater()
        {
            this.rptItem.DataSource = this.CurrentItems;
            this.rptItem.DataBind();
        }

        #endregion

        #region Internal Class

        private class OrderItem
        {
            public int ItemNumber = 0;
            public int PartNumber;
            public int PatterNo;
            public int GarmentStyle;
            public int Fabric;
            public bool Pocket;
            public List<OrderItemRow> ListItemRow = new List<OrderItemRow>();

            public OrderItem(int CurrentItem)
            {
                ItemNumber = CurrentItem + 1;
                for (int j = 0; j < 10; j++)
                {
                    ListItemRow.Add(new OrderItemRow());
                }
            }
        }

        private class OrderItemRow
        {
            public int AgeGroup;
            public int Size;
            public int Qty;
            public decimal Price;
            public decimal Value;
        }

        #endregion
    }
}