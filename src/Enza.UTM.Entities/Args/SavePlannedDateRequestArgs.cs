using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Enza.UTM.Entities.Args
{
    public class SavePlannedDateRequestArgs
    {
        public int TestID { get; set; }
        public DateTime PlannedDate { get; set; }
    }
}
