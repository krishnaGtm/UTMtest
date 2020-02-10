using System;

namespace Enza.UTM.Entities
{
    public class Test
    {
        public int TestID { get; set; }
        public int StatusCode { get; set; }
    }

    public class TestLookup
    {
        public int TestID { get; set; }
        public string TestName { get; set; }
        public int TestTypeID { get; set; }
        public string TestTypeName { get; set; }
        public string Remark { get; set; }
        public bool RemarkRequired { get; set; }
        public int StatusCode { get; set; }
        public bool FixedPostionAssigned { get; set; }
        public int? MaterialStateID { get; set; }
        public int? MaterialTypeID { get; set; }
        public int? ContainerTypeID { get; set; }
        public bool MaterialReplicated { get; set; }
        public DateTime PlannedDate { get; set; }
        public bool Isolated { get; set; }
        public int? SlotID { get; set; }
        public int WellsPerPlate { get; set; }
        public string BreedingStationCode { get; set; }
        public string CropCode { get; set; }
        public DateTime ExpectedDate { get; set; }
        public string SlotName { get; set; }
        public string PlatePlanName { get; set; }
        public string Source { get; set; }
        public bool Cumulate { get; set; }
        public string ImportLevel { get; set; }
    }

    public class TestForLIMS
    {
        public string CropCode { get; set; }
        public int? PlannedWeek { get; set; }
        public int? PlannedYear { get; set; }
        public int TotalPlates { get; set; }
        public int TotalTests { get; set; }
        public string SynCode { get; set; }
        public string Remark { get; set; }
        public string Isolated { get; set; }
        public string MaterialState { get; set; }
        public string MaterialType { get; set; }
        public string ContainerType { get; set; }
        public int? ExpectedWeek { get; set; }
        public int? ExpectedYear { get; set; }
        public string CountryCode { get; set; } 
        public string PlannedDate { get; set; } 
        public string ExpectedDate { get; set; } 

    }
}
