using Enza.UTM.Common.Extensions;
using System.Collections.Generic;
using System.Data;
using System.Linq;

namespace Enza.UTM.Entities.Args
{
    public class ReceiveRDTResultsRequestArgs
    {
        public int RequestID { get; set; }
        public int TestFlowType { get; set; }
        public string RequestingUser { get; set; }
        public string RequestingSystem { get; set; }
        public List<DeterminationReceiveResult> Determinations { get; set; }

        public DataTable ToTVPRDTScore()
        {
            var dt = new DataTable("TVP_RDTScore");
            dt.Columns.Add("OriginID", typeof(int));
            dt.Columns.Add("MaterialID", typeof(int));
            dt.Columns.Add("Score", typeof(string));
            dt.Columns.Add("SusceptibilityPercent", typeof(decimal));
            dt.Columns.Add("ValueColumn", typeof(string));
            foreach (var item in Determinations)
            {
                foreach (var data in item.Materials)
                {
                    foreach(var score in data.Scores)
                    {
                        var dr = dt.NewRow();
                        dr["OriginID"] = item.DeterminationID;
                        dr["MaterialID"] = data.MaterialID;

                        // for flow 2 either SusceptibilityPer or Score
                        if (score.Key.ToLower().Contains("susceptibilityper"))
                            dr["SusceptibilityPercent"] = score.Value;
                        else
                        {
                            // fill ValueColumn only for testflowtype 3
                            if(!score.Key.EqualsIgnoreCase("Score"))
                                dr["ValueColumn"] = score.Key;

                            dr["Score"] = score.Value;
                        }

                        dt.Rows.Add(dr);
                    }
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
        public List<ScoreReceiveResult> Scores { get; set; }
    }

    public class ScoreReceiveResult
    {
        public string Key { get; set; }
        public string Value { get; set; }
    }

    public class ReceiveRDTResultsReceiveResult
    {
        public string Success { get; set; }
        public string ErrorMsg { get; set; }
    }
}
