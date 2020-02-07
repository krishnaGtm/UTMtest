namespace Enza.UTM.Entities
{
    public class TestMaterialDeterminationWithScore
    {
        //public string CropCode { get; set; }
        public int MaterialID { get; set; }
        public int DeterminationID { get; set; }  
        public bool? Selected { get; set; }
        public string AlliceScore { get; set; }
        //public int? DH0net { get; set; }
        //public int? Requested { get; set; }
        //public int? Transplant { get; set; }
        //public int? ToBeSown { get; set; }

    }
    public class S2SDonorInfo
    {
        public int MaterialID { get; set; }
        public int? DH0net { get; set; }
        public int? Requested { get; set; }
        public int? Transplant { get; set; }
        public int? ToBeSown { get; set; }
        public string DonorNumber { get; set; }
        public string ProjectCode { get; set; }

    }
}
