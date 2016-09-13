using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace IndicoService.Models
{
    public class PatternDetailModel
    {
        public int Pattern = 0;
        public string NickName = string.Empty;
        public string Number = string.Empty;
        public string Remarks = string.Empty;
        public string Description = string.Empty;
        public string Gender = string.Empty;        
        public string GarmentImagePath1 = string.Empty;
        public string GarmentImagePath2 = string.Empty;
        public string GarmentImagePath3 = string.Empty;
        public string GarmentSpecImagePath = string.Empty;
        public string GarmentSpecChartImagePath = string.Empty;
        public List<MeasurementLocation> ListMeasurementLocations = new List<MeasurementLocation>();
        public Exception Ex;
    }

    public class Size
    {
        public string name = string.Empty;
        public string Value = string.Empty;
    }

    public class MeasurementLocation
    {
        public string Name = string.Empty;
        public List<Size> ListSizes = new List<Size>();
    }
}