using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Enza.UTM.Entities.Results
{
    public class S2SCapacitySlotResult
    {
        public int CapacitySlotID { get; set; }
        public string SowingCode { get; set; }
        public DateTime SowingDate { get; set; }
        public string Status { get; set; }
        public int MaxPlants { get; set; }
        public DateTime ExpectedDeliveryDate { get; set; }
        public string DH0Location { get; set; }
        public int AvailableNrPlants { get; set; }

    }
}
