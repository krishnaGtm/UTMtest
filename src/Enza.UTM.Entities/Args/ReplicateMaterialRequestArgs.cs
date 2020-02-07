using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Enza.UTM.Entities.Args
{
    public class ReplicateMaterialRequestArgs
    {
        public ReplicateMaterialRequestArgs()
        {
            ReplicateMaterial = new List<int>();
        }
        public int TestID { get; set; }
        public int NoOfReplicate { get; set; }
        public bool Collated { get; set; }
        public List<int> ReplicateMaterial { get; set; }
        
        public DataTable ToReplicateMaterial()
        {
            var dt = new DataTable("TVP_Material_Rep");
            dt.Columns.Add("MaterialID", typeof(int));
            foreach (var _item in ReplicateMaterial)
            {
                var dr = dt.NewRow();
                dr["MaterialID"] = _item;
                dt.Rows.Add(dr);
            }
            return dt;
        }
    }
}
