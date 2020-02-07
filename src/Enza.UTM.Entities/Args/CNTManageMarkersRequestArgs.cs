using Enza.UTM.Entities.Args.Abstract;
using System.Collections.Generic;

namespace Enza.UTM.Entities.Args
{
    public class CNTManageMarkersRequestArgs : RequestArgs
    {
        public CNTManageMarkersRequestArgs()
        {
            Markers = new List<CNTManagerMarkerInfo>();
        }
        public int TestID { get; set; }
        public List<CNTManagerMarkerInfo> Markers { get; set; }
    }

    public class CNTManagerMarkerInfo
    {
        public int MaterialID { get; set; }
        public int DeterminationID { get; set; }
        public bool Selected { get; set; }
    }
}
