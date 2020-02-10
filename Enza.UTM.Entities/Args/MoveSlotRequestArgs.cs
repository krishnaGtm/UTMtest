using System;

namespace Enza.UTM.Entities.Args
{
    public class MoveSlotRequestArgs
    {
        public int SlotID { get; set; }
        public DateTime PlannedDate { get; set; }
        public DateTime ExpectedDate { get; set; }
    }
}
