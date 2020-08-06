using System.Collections.Generic;
using System.Data;

namespace Enza.UTM.Entities.Args
{
    public class ReceiveRDTResultsRequestArgs
    {
        public int RequestID { get; set; }
        public string RequestingUser { get; set; }
        public string RequestingSystem { get; set; }
        public List<DeterminationReceiveResult> Determinations { get; set; }

        public DataTable ToTVPRDTScore()
        {
            var dt = new DataTable("TVP_RDTScore");
            dt.Columns.Add("DeterminationID", typeof(int));
            dt.Columns.Add("MaterialID", typeof(int));
            dt.Columns.Add("Score", typeof(string));
            foreach (var item in Determinations)
            {
                foreach (var data in item.Materials)
                {
                    var dr = dt.NewRow();
                    dr["DeterminationID"] = item.DeterminationID;
                    dr["MaterialID"] = data.MaterialID;
                    dr["Score"] = data.Score;
                    dt.Rows.Add(dr);
                }
            }
            return dt;
        }
    }

    public class DeterminationReceiveResult
    {
        public int DeterminationID { get; set; }
        public List<MaterialReceiveResult> Materials { get; set; }
    }

    public class MaterialReceiveResult
    {
        public int MaterialID { get; set; }
        public string Score { get; set; }
    }

    public class ReceiveRDTResultsReceiveResult
    {
        public string Success { get; set; }
        public string ErrorMsg { get; set; }
    }
}
