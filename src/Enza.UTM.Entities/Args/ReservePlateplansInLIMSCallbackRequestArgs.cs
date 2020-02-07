using System.Collections.Generic;
using System.Data;

namespace Enza.UTM.Entities.Args
{
    public class ReservePlateplansInLIMSCallbackRequestArgs
    {
        public string SyncCode { get; set; }
        public string UserID { get; set; }
        public int LIMSPlatePlanID { get; set; }
        public string LIMSPlatePlanName { get; set; }
        public int TestID { get; set; }
        public List<Plate> Plates { get; set; }
        public DataTable ToTVPPlates()
        {
            var dt = new DataTable("TVP_Plates");
            dt.Columns.Add("LIMSPlateID", typeof(int));
            dt.Columns.Add("LIMSPlateName", typeof(string));            
            foreach (var item in Plates)
            {
                var dr = dt.NewRow();
                dr["LIMSPlateID"] = item.LIMSPlateID;
                dr["LIMSPlateName"] = item.LIMSPlateName;                
                dt.Rows.Add(dr);
            }
            return dt;
        }

    }
    public class Plate
    {
        public int LIMSPlateID { get; set; }
        public string LIMSPlateName { get; set; }
    }
}
