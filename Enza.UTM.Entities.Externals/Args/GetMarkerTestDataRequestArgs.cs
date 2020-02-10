using Enza.UTM.Entities.Externals.Args.Abstract;

namespace Enza.UTM.Entities.Externals.Args
{
    public class GetMarkerTestDataRequestArgs : RequestArgs
    {
        public int MaterialID { get; set; }
        public int TestID { get; set; }//Infact, it is MaterialID
    }
}
