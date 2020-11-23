using System;

namespace Enza.UTM.Entities.Args
{
    public class EditSlotRequestArgs
    {
        public int SlotID { get; set; }
        public int NrOfPlates { get; set; }
        public DateTime? PlannedDate { get; set; }
        public DateTime? ExpectedDate { get; set; }
        public int NrOfTests { get; set; }
        public bool Forced { get; set; }
    }
}
