using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Enza.UTM.Entities.Results
{
    public class TestResultCumulate
    {
        //public int MaterialID { get; set; }
        public string ListID { get; set; }
        //MaterialKey is equivalent to entry code for list and plant name for plant.
        public string MaterialKey { get; set; }
        public int DeterminationID { get; set; }
        public string Score { get; set; }
        public string DetScore { get; set; }
        public string ColumnLabel { get; set; }
        public decimal InvalidPer { get; set; }

    }
    public class TestResultToCreate
    {
        public string ListID { get; set; }
        //public int DeterminationID { get; set; }
        public string Materialkey { get; set; }
        public List<Scores> Score { get; set; }
        //public int TestID { get; set; }
        public bool Same { get; set; }
        public int Count { get; set; }
        public int UndefinedCount { get; set; }
        public decimal AcceptablePercentage { get; set; }
        public string FinalScore { get; set; }
        public string ColumnLabel { get; set; }
    }
    public class Scores
    {
        public string Score { get; set; }
        public string DetScore { get; set; }
    }
}
