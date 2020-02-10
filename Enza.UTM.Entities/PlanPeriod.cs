using System;

namespace Enza.UTM.Entities
{
    public class PlanPeriod
    {
        public int PeriodID { get; set; }
        public string PeriodName { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public string Remark { get; set; }
        public bool Selected { get; set; }
    }
}
