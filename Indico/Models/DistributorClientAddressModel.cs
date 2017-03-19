namespace Indico.Models
{
    public class DistributorClientAddressModel
    {
        public int ID { get; set; }
        public string Address { get; set; }
        public string Suburb { get; set; }
        public string PostCode { get; set; }
        public int Country { get; set; }
        public string ContactName { get; set; }
        public string ContactPhone { get; set; }
        public string CompanyName { get; set; }
        public string State { get; set; }
        public int? Port { get; set; }
        public string EmailAddress { get; set; }
        public int? AddressType { get; set; }
        public int? Client { get; set; }
        public bool IsAdelaideWarehouse { get; set; }
        public int? Distributor { get; set; }
    }
}