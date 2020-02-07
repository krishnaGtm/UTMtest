using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Enza.UTM.Entities.Args
{
    public class DeleteReplicateMaterialRequestArgs
    {
        //public DeleteReplicateMaterialRequestArgs()
        //{
        //    Material = new List<ReplicateMaterial>();
        //}
        //public List<ReplicateMaterial> Material { get; set; }
        public int TestID { get; set; }
        public int MaterialID { get; set; }
        public int WellID { get; set; }
        //public class ReplicateMaterial
        //{
        //    public int MaterialID { get; set; }
        //    public int WellID { get; set; }
        //}
    }
}
