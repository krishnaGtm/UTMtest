using System.Collections.Generic;

namespace Enza.UTM.Entities.Externals.Args
{
    public class StoreDH0RequestArgs
    {
        public StoreDH0RequestArgs()
        {
            DH0List = new List<DH0Info>();
        }
        public int TestID { get; set; }
        public int MaterialID { get; set; }
        public List<DH0Info> DH0List { get; set; }

    }

    public class DH0Info
    {
        public DH0Info()
        {
            Markers = new List<DH0MarkerInfo>();
        }
        public string ProposedName { get; set; }

        public List<DH0MarkerInfo> Markers { get; set; }
    }

    public class DH0MarkerInfo
    {
        public int MarkerNumber { get; set; }
        public string Score { get; set; }
    }
}
