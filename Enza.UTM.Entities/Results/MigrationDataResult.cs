using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Enza.UTM.Entities.Results
{
    public class MigrationDataResult
    {
        public int TestID { get; set; }
        public string TestName { get; set; }
        //public int TraitID { get; set; }
        //public string TraitName { get; set; }
        public string ColumnLabel { get; set; }
        public int DeterminationID { get; set; }
        public string DeterminationName { get; set; }
        public string DeterminationValue { get; set; }
        public string RequestingUser { get; set; }
        public int StatusCode { get; set; }
        public string CropCode { get; set; }
        //this is unique key of material which is plant in our case One GID can have multiple plant
        public string Materialkey { get; set; }
        
        public int? ListID { get; set; }
        public string TraitValue { get; set; }
        public bool Cummulate { get; set; }
        public decimal InvalidPer { get; set; }
        public string FieldID { get; set; }
        public bool IsValid { get; set; }
        public int WellID { get; set; }

        public bool Added { get; set; }

        public string Position { get; set; }
        public string PlateName { get; set; }

    }
    public class InvalidConversion
    {
        public string Determination { get; set; }
        public string Trait { get; set; }
        public string DeterminationVal { get; set; }
        public bool IsValid { get; set; }
    }

    public class TraitDeterminationResultTest
    {
        public int TestID { get; set; }
        public string TestName { get; set; }
        public int StatusCode { get; set; }

    }

    public class UTMResult
    {
        public string Materialkey { get; set; }
        public string Observationkey { get; set; }
        public bool Added { get; set; }
       
    }
    
}
