using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Enza.UTM.Entities
{
    public class EmailDataArgs
    {
        public String ReservationNumber { get; set; }
        public DateTime PlannedDate { get; set; }
        public DateTime ChangedPlannedDate { get; set; }
        public DateTime ExpectedDate { get; set; }
        public DateTime ChangedExpectedDate { get; set; }
        public string Action { get; set; }
        public string PeriodName { get; set; }
        public string ChangedPeriodName { get; set; }
        public string SlotName { get; set; }
        public string RequestUser { get; set; }
        public string ExpectedPeriodName { get; set; }
        public string ChangedExpectedPeriodName { get; set; }

    }
}
