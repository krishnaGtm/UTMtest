using System.Collections.Generic;
using System.Data;
using System.Linq;
using Enza.UTM.Entities.Args.Abstract;

namespace Enza.UTM.Entities.Args
{
    public class AssignDeterminationRequestArgs: PagedRequestArgs
    {
        public AssignDeterminationRequestArgs()
        {
            MaterialWithMarker = new List<TestMaterialDetermination>();
            Determinations = new List<int>();
        }        
        public int TestTypeID { get; set; }
        public int TestID { get; set; }
        public List<TestMaterialDetermination> MaterialWithMarker { get; set; }
        public List<int> Determinations { get; set; }
        public DataTable ToTVPTestMaterialDetermation()
        {
            var dt = new DataTable("TVP_TMD");            
            dt.Columns.Add("MaterialID", typeof(int));
            dt.Columns.Add("DeterminationID", typeof(int));
            dt.Columns.Add("Selected", typeof(bool));
            foreach (var item in MaterialWithMarker)
            {
                var dr = dt.NewRow();
                dr["MaterialID"] = item.MaterialID;
                dr["DeterminationID"] = item.DeterminationID;
                dr["Selected"] = item.Selected;
                dt.Rows.Add(dr);
            }
            return dt;
        }
        public DataTable ToTVPDeterminations()
        {
            var dt = new DataTable("TVP_Determinations");
            dt.Columns.Add("DeterminationID", typeof(int));
            foreach (var _item in Determinations)
            {
                var dr = dt.NewRow();
                dr["DeterminationID"] = _item;
                dt.Rows.Add(dr);
            }
            return dt;
        }
        public string ToColumnsString()
        {
            var col = string.Join(", ", Filter.Select(x => $"'{x.Name}'").ToArray());
            return col;
        }
    }
}
