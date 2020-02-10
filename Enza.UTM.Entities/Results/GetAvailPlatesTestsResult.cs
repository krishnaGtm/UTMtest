using System;

namespace Enza.UTM.Entities.Results
{
    public class GetAvailPlatesTestsResult
    {
        public string DisplayPlannedWeek { get; set; }
        public DateTime ExpectedDate { get; set; }
        public string DisplayExpectedWeek { get; set; }
        public int? AvailPlates { get; set; }
        public int? AvailTests { get; set; }
    }
}
