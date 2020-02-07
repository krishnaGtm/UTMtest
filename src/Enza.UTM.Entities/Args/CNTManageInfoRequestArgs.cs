using Enza.UTM.Entities.Args.Abstract;
using System;
using System.Collections.Generic;

namespace Enza.UTM.Entities.Args
{
    public class CNTManageInfoRequestArgs : RequestArgs
    {
        public CNTManageInfoRequestArgs()
        {
            Materials = new List<CNTMaterialInfo>();
            Details = new List<CNTManageInfo>();
        }
        public int TestID { get; set; }
        public List<CNTMaterialInfo> Materials { get; set; }
        public List<CNTManageInfo> Details { get; set; }
    }

    public class CNTManageInfo
    {
        public int MaterialID { get; set; }
        public string DonorNumber { get; set; }
        public int? ProcessID { get; set; }
        public int? LabLocationID { get; set; }
        public int? StartMaterialID { get; set; }
        public int? TypeID { get; set; }
        public int? Requested { get; set; }
        public int? Transplant { get; set; }
        public int? Net { get; set; }
        public DateTime? RequestedDate { get; set; }
        public DateTime? DH1ReturnDate { get; set; }
        public string Remarks { get; set; }
    }

    public class CNTMaterialInfo
    {
        public int MaterialID { get; set; }
        public bool Selected { get; set; }
    }
}
