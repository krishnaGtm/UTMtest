using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Enza.UTM.Entities.Args
{
    public class ReserveCapacityRequestArgs
    {
        public string BreedingStationCode { get; set; }
        public string CropCode { get; set; }
        public int TestTypeID { get; set; }
        public int MaterialTypeID { get; set; }
        public int MaterialStateID { get; set; }
        public bool Isolated { get; set; }
        //public int CurrentPeriod { get; set; } //Current period id is represended as current date 
        public DateTime PlannedDate { get; set; }
        public DateTime ExpectedDate { get; set; }
        public int NrOfPlates { get; set; }
        public int NrOfTests { get; set; }
        public bool Forced { get; set; }
    }
}
