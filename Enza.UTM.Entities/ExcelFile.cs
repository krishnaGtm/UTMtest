using System;

namespace Enza.UTM.Entities
{
    public class ExcelFile
    {
        public int FileID { get; set; }
        public int TestID { get; set; }
        public int TestTypeID { get; set; }
        public string CropCode { get; set; }
        public string FileTitle { get; set; }
        public string UserID { get; set; }
        public DateTime ImportDateTime { get; set; }
        public string Remark { get; set; }
        public bool RemarkRequired { get; set; }
        public int StatusCode { get; set; }
        public int? MaterialstateID { get; set; }
        public int? MaterialTypeID { get; set; }
        public int? ContainerTypeID { get; set; }
        public bool Isolated { get; set; }
        public DateTime PlannedDate { get; set; }
        public int? SlotID { get; set; }
        public int WellsPerPlate { get; set; }
        public string BreedingStationCode { get; set; }
        public DateTime ExpectedDate { get; set; }
        public string PlatePlanName { get; set; }
        public string Source { get; set; }
        public bool Cumulate { get; set; }
        public string ImportLevel { get; set; }
    }
}
