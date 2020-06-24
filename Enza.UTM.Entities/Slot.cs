using System;

namespace Enza.UTM.Entities
{
    public class SlotLookUp
    {
        public int SlotID { get; set; }
        public string SlotName { get; set; }
        public string BreedingStationCode { get; set; }
        public string CropCode { get; set; }
        public string RequestUser { get; set; }
        public string TestType { get; set; }
        public string MaterialType { get; set; }
        public string MaterialState { get; set; }
        public bool Isolated { get; set; }
        public string TestProtocolName { get; set; }
        public int NrOfPlates { get; set; }
        public int NrOfTests { get; set; }
        public DateTime PlannedDate { get; set; }
        public DateTime ExpectedDate { get; set; }
    }

    public class Slot
    {
        public int SlotID { get; set; }
        public string SlotName { get; set; }
        public string Remarks { get; set; }
    }
}
