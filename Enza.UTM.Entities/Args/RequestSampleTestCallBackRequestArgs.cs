using System;
using System.Collections.Generic;
using System.Data;

namespace Enza.UTM.Entities.Args
{
    public class RequestSampleTestCallBackRequestArgs
    {
        public string Crop { get; set; }
        public string BrStation { get; set; }
        public string Country { get; set; }
        public string Level { get; set; }
        public string TestType { get; set; }
        public int RequestID { get; set; }
        public string RequestingUser { get; set; }
        public string RequestingName { get; set; }
        public string RequestingSystem { get; set; }
        public List<Determination> Determinations { get; set; }

        public DataTable ToTVPMaterial()
        {
            var dt = new DataTable("TVP_Plates");
            dt.Columns.Add("LIMSPlateID", typeof(int));
            dt.Columns.Add("LIMSPlateName", typeof(string));
            //foreach (var item in Plates)
            //{
            //    var dr = dt.NewRow();
            //    dr["LIMSPlateID"] = item.LIMSPlateID;
            //    dr["LIMSPlateName"] = item.LIMSPlateName;
            //    dt.Rows.Add(dr);
            //}
            return dt;
        }
    }

    public class Determination
    {
        public int DeterminationID { get; set; }
        public CreatedPlants CreatedPlants { get; set; }
        public List<Material> Materials { get; set; }
    }

    public class CreatedPlants
    {
        public int NrPlants { get; set; }
    }

    public class Material
    {
        public int MaterialID { get; set; }
        public int NL_INTERFACE_REFID { get; set; }
        public string Name { get; set; }
        public DateTime ExpectedResultDate { get; set; }
        public string MaterialStatus { get; set; }
    }

    public class RequestSampleTestCallbackResult
    {
        public string Success { get; set; }
        public string ErrorMsg { get; set; }
    }
}
