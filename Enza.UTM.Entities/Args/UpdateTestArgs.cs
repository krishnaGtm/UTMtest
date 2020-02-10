using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Enza.UTM.Entities.Args
{
    public class UpdateTestArgs
    {
        public int TestID { get; set; }
        public DateTime PlannedDate { get; set; }
        public DateTime ExpectedDate { get; set; }
        public int? MaterialTypeID { get; set; }
        public int? ContainerTypeID { get; set; }
        public bool Isolated { get; set; }
        public int TestTypeID { get; set; }
        public int? MaterialStateID { get; set; }       
        public bool Cumulate { get; set; }
    }
}
