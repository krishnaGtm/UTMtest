using Enza.UTM.Common.Attributes;
using System;

namespace Enza.UTM.Entities.Args
{
    public class UpdateSlotPeriodRequestArgs:EditSlotRequestArgs
    {
        //public int SlotID { get; set; }
        public DateTime? PlannedDate { get; set; }
        public DateTime? ExpectedDate { get; set; }
        [SwaggerExclude]
        public bool AllowOverride { get; set; }
    }
}
