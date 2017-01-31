
namespace Indico.Models
{
    public class InvItemModel
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string Category { get; set; }
        public int CategoryID { get; set; }
        public string SubCategory { get; set; }
        public int SubCategoryID { get; set; }
        public string Colour { get; set; }
        public string Attribute { get; set; }
        public int MinLevel { get; set; }
        public string Uom { get; set; }
        public int UomID { get; set; }
        public string SupplierCode { get; set; }
        public int SupplierCodeID { get; set; }
        public string Purchaser { get; set; }
        public int PurchaserID { get; set; }
       
        public string Status { get; set; }

        public string Code { get; set; }

        public void SetStatus()
        {
            if (Status == "0")
            {
                Status = "Inactive";

            }
            else
            {
                Status = "Active";
            }
        }
    }
}