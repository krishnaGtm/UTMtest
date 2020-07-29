using System;
using System.Collections.Generic;
using System.Data;

namespace Enza.UTM.Entities.Args
{
    public class PrintLabelForRDTRequestArgs
    {
        public PrintLabelForRDTRequestArgs()
        {
            MaterialStatus = new List<string>();
            MaterialDeterminations = new List<MaterialDetermination>();
        }
        public int TestID { get; set; }
        public List<string> MaterialStatus { get; set; }
        public List<MaterialDetermination> MaterialDeterminations { get; set; }

        public DataTable ToTMDTable()
        {
            var dt = new DataTable("TVP_TMD");
            dt.Columns.Add("MaterialID", typeof(int));
            dt.Columns.Add("DeterminationID", typeof(int));
            dt.Columns.Add("Selected", typeof(bool));
            foreach (var item in MaterialDeterminations)
            {
                var dr = dt.NewRow();
                dr["DeterminationID"] = item.DeterminationID;
                dr["MaterialID"] = item.MaterialID;
                dr["Selected"] = true;
                dt.Rows.Add(dr);
            }
            return dt;
        }
    }
    public class MaterialDetermination
    {
        public int MaterialID { get; set; }
        public int DeterminationID { get; set; }
    }
}
