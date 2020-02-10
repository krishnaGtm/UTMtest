using System;
using System.Collections.Generic;
using System.Data;

namespace Enza.UTM.Entities.Args
{
    public class ReceiveScoreArgs
    {
        public int RequestID { get; set; } //this is equivalent to TestID of Test table        
        public List<ScoreResultData> ScoreResults { get; set; }
        public DataTable ToScoreResultDataTable()
        {
            var dt = new DataTable("TVP_ScoreResult");
            dt.Columns.Add("ScoreVal", typeof(string));
            dt.Columns.Add("Determination", typeof(int));
            dt.Columns.Add("Position", typeof(string));
            dt.Columns.Add("LimsPlateID", typeof(int));
            foreach (var item in ScoreResults)
            {
                var dr = dt.NewRow();
                dr["ScoreVal"] = item.ScoreVal;
                dr["Determination"] = item.Determination;
                dr["Position"] = item.Position;
                dr["LimsPlateID"] = item.LimsPlateID;
                dt.Rows.Add(dr);
            }
            return dt;
        }
    }
    
    public class ScoreResultData
    {
        public string ScoreVal { get; set; }
        public int? Determination { get; set; }
        //public int? PlateColumn { get; set; }
        public string Position { get; set; }
        public int? LimsPlateID { get; set; }
    }
    

}
