using Enza.UTM.Entities.Args.Abstract;

namespace Enza.UTM.Entities.Args
{
    public class BreedingOverviewRequestArgs: PagedRequestArgs
    {
        public string CropCode { get; set; }
        public string BrStationCode { get; set; }
    }
}
