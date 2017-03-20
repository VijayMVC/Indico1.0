namespace Indico.Models
{
    public class CountryModel
    {
        public int ID { get; set; }
        public string Iso2 { get; set; }
        public string Iso3 { get; set; }
        public int IsoCountryNumber { get; set; }
        public int? DialingPrefix { get; set; }
        public string Name { get; set; }
        public string ShortName { get; set; }
        public bool HasLocationData { get; set; }
    }
}