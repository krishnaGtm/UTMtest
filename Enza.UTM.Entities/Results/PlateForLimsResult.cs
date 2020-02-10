using System.Collections.Generic;

namespace Enza.UTM.Entities.Results
{
    public class PlateForLimsResult
    {
        public PlateForLimsResult()
        {
            Plates = new List<PlateInfo>();
        }
        public string CropCode { get; set; }
        public int? LimsPlatePlanID { get; set; }
        public int RequestID { get; set; }
        public List<PlateInfo> Plates { get; set; }
    }

    public class WellInfo
    {
        public string PlateColumn { get; set; }
        public string PlateRow { get; set; }
        public string PlantNr { get; set; }
        public string PlantName { get; set; }
        public string BreedingStationCode { get; set; }
    }

    public class MarkerInfo
    {
        public int MarkerNr { get; set; }
        public string MarkerName { get; set; }
    }

    public class PlateInfo
    {
        public PlateInfo()
        {
            Markers = new List<MarkerInfo>();
            Wells = new List<WellInfo>();
        }
        public int LimsPlateID { get; set; }
        public string LimsPlateName { get; set; }
        public List<MarkerInfo> Markers { get; set; }
        public List<WellInfo> Wells { get; set; }
    }
}
