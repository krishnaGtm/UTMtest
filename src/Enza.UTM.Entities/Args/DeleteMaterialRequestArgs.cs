using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Enza.UTM.Entities.Args
{
    public class DeleteMaterialRequestArgs
    {
        public DeleteMaterialRequestArgs()
        {
            WellIDs = new List<int>();
        }
        //public int? MaterialID { get; set; }
        public List<int> WellIDs { get; set; }
        //public int? WellID { get; set; }
        public int TestID { get; set; }        
    }
}
