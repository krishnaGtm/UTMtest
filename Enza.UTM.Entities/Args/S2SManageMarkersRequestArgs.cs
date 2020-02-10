using System.Collections.Generic;

namespace Enza.UTM.Entities.Args
{
    public class S2SManageMarkersRequestArgs 
    {
        public S2SManageMarkersRequestArgs()
        {
            Details = new List<S2SManageMarkerInfo>();
        }
        public int TestID { get; set; }

        public List<S2SManageMarkerInfo> Details { get; set; }
    }
    public class S2SManageMarkerInfo
    {
        public int DeterminationID { get; set; }
        public int MaterialID { get; set; }
    }
}
