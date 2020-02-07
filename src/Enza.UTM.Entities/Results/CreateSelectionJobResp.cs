using System.Collections.Generic;

namespace Enza.UTM.Entities.Results
{
    public class CreateSelectionJobResp
    {
        public string Job_id { get; set; }
        public string Status { get; set; }

    }
    public class JobStatus
    {
        public JobStatus()
        {
            JobList = new List<CreateSelectionJobResp>();

        }
        public List<CreateSelectionJobResp> JobList { get; set; }
    }
}
