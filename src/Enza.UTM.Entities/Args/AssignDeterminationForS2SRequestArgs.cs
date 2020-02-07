using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using Enza.UTM.Entities.Args.Abstract;

namespace Enza.UTM.Entities.Args
{
    public class AssignDeterminationForS2SRequestArgs : PagedRequestArgs
    {
        public AssignDeterminationForS2SRequestArgs()
        {
            MaterialWithMarkerAndScore = new List<TestMaterialDeterminationWithScore>();
            DonerInfo = new List<S2SDonorInfo>();
            Determinations = new List<int>();
        }        
        public int TestTypeID { get; set; }
        public int TestID { get; set; }
        public List<TestMaterialDeterminationWithScore> MaterialWithMarkerAndScore { get; set; }
        public List<S2SDonorInfo> DonerInfo { get; set; }
        public List<int> Determinations { get; set; }
        public DataTable ToTVPTestMaterialDetermation()
        {
            var dt = new DataTable("TVP_TMD");            
            dt.Columns.Add("MaterialID", typeof(int));
            dt.Columns.Add("DeterminationID", typeof(int));
            dt.Columns.Add("Selected");
            dt.Columns.Add("AlliceScore", typeof(string));
            foreach (var item in MaterialWithMarkerAndScore)
            {
                var dr = dt.NewRow();
                dr["MaterialID"] = item.MaterialID;
                dr["DeterminationID"] = item.DeterminationID;
                dr["Selected"] = item.Selected;
                dr["AlliceScore"] = item.AlliceScore;
                dt.Rows.Add(dr);
            }
            return dt;
        }
        public DataTable ToTVPDonerInfo()
        {
            var dt = new DataTable("TVP_DonerInfo");
            dt.Columns.Add("MaterialID", typeof(int));
            dt.Columns.Add("DH0net");
            dt.Columns.Add("Requested");
            dt.Columns.Add("ToBeSown");
            dt.Columns.Add("Transplant");
            dt.Columns.Add("DonorNumber");
            dt.Columns.Add("ProjectCode");
            foreach (var item in DonerInfo)
            {
                var dr = dt.NewRow();
                dr["MaterialID"] = item.MaterialID;
                dr["DH0net"] = item.DH0net;
                dr["Requested"] = item.Requested;
                dr["ToBeSown"] = item.ToBeSown;
                dr["Transplant"] = item.Transplant;
                dr["DonorNumber"] = item.DonorNumber;
                dr["ProjectCode"] = item.ProjectCode;
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
