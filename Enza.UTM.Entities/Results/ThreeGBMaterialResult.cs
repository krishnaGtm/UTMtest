using System.Collections.Generic;

namespace Enza.UTM.Entities.Results
{
    public class ThreeGBMaterialResult
    {
        public string BreEZysAdministrationCode { get; set; }
        public int ThreeGBTaskID { get; set; }
        public string PlantNumber { get; set; }
        public string BreedingProject { get; set; }
        public string PlantID { get; set; }
        public string Generation { get; set; }
        public string TwoGBPlatePlanID { get; set; }
        public string TwoGBPlateNumber { get; set; }
        public string TwoGBRow { get; set; }
        public string TwoGBColumn { get; set; }
        public int? TwoGBWeek { get; set; }
        public string Purpose { get; set; }
        public string Remark { get; set; }
        public string MarkerName { get; set; }
        public string Result { get; set; } 
    }

}
