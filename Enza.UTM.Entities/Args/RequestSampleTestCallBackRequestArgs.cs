using Enza.UTM.Entities.Results;
using System;
using System.Collections.Generic;
using System.Data;

namespace Enza.UTM.Entities.Args
{
    public class RequestSampleTestCallBackRequestArgs
    {
        //public string Crop { get; set; }
        //public string BrStation { get; set; }
        //public string Country { get; set; }
        //public string Level { get; set; }
        //public string TestType { get; set; }
        public int RequestID { get; set; }
        public string FolderName { get; set; }
        //public string RequestingUser { get; set; }
        //public string RequestingName { get; set; }
        //public string RequestingSystem { get; set; }
        public List<DeterminationCallback> Determinations { get; set; }

        public DataTable ToTVPDeterminationMaterial()
        {
            var dt = new DataTable("TVP_DeterminationMaterial");
            dt.Columns.Add("DeterminationID", typeof(int));
            dt.Columns.Add("MaterialID", typeof(int));
            dt.Columns.Add("NrPlants", typeof(int));
            dt.Columns.Add("LimsRefID", typeof(int));
            foreach (var item in Determinations)
            {
                foreach(var data in item.Materials )
                {

                    var dr = dt.NewRow();
                    dr["DeterminationID"] = item.DeterminationID;
                    dr["MaterialID"] = data.MaterialID;
                    dr["NrPlants"] = data.NrPlants;
                    dr["LimsRefID"] = data.InterfaceRefID;
                    dt.Rows.Add(dr);
                }
            }
            return dt;
        }
    }

    public class DeterminationCallback
    {
        public int DeterminationID { get; set; }
        public List<MaterialCallback> Materials { get; set; }
    }

    public class MaterialCallback
    {
        public int MaterialID { get; set; }
        public int NrPlants { get; set; }
        public int InterfaceRefID { get; set; }
    }

    public class RequestSampleTestCallbackResult
    {
        public string Success { get; set; }
        public string ErrorMsg { get; set; }
    }
}
