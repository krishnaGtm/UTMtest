using System.Collections.Generic;
using System.Data;

namespace Enza.UTM.Entities.Args
{
    public class SaveCapacityRequestArgs
    {
        public SaveCapacityRequestArgs()
        {
            CapacityList = new List<CapacityLookup>();
        }

        public List<CapacityLookup> CapacityList { get; set; }

        public DataTable ToTVPCapacity()
        {
            var dt = new DataTable("TVP_Capacity");
            dt.Columns.Add("PeriodID", typeof(int));
            dt.Columns.Add("PivotedColumn", typeof(string));
            dt.Columns.Add("Value", typeof(string));
            foreach (var _item in CapacityList)
            {
                var dr = dt.NewRow();
                dr["PeriodID"] = _item.PeriodID;
                dr["PivotedColumn"] = _item.TestProtocolID;
                dr["Value"] = _item.Value;
                dt.Rows.Add(dr);
            }
            return dt;
        }
    }
}
