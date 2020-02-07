using System.Collections.Generic;

namespace Enza.UTM.Entities.Args
{
    public class SaveNrOfSamplesRequestArgs
    {
        public SaveNrOfSamplesRequestArgs()
        {
            Samples = new List<NrOfSampleItem>();
        }
        public int FileID { get; set; }

        public List<NrOfSampleItem> Samples { get; set; }
    }

    public class NrOfSampleItem
    {
        public int MaterialID { get; set; }
        public int NrOfSample { get; set; }
    }
}
