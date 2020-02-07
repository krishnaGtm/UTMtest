using System.Collections.Generic;
using System.Data;

namespace Enza.UTM.Entities.Args
{
    public class ReOrderMaterialPositionRequestArgs
    {
        public ReOrderMaterialPositionRequestArgs()
        {
            MaterialWell = new List<Entities.MaterialWell>();
        }

        public List<MaterialWell> MaterialWell { get; set; }
        public int TestID { get; set; }

        public DataTable ToTVPMaterialWell()
        {
            var dt = new DataTable("TVP_TMDW");
            dt.Columns.Add("WellID", typeof(int));
            dt.Columns.Add("MaterialID", typeof(int));
            foreach (var _item in MaterialWell )
            {
                var dr = dt.NewRow();
                dr["WellID"] = _item.WellID;
                dr["MaterialID"] = _item.MaterialID;
                dt.Rows.Add(dr);
            }
            return dt;
        }
    }
}
