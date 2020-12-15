namespace Enza.UTM.Entities
{
    public class RDTScore
    {
        public int TestID { get; set; }
        public int? ObservationID { get; set; }
        public int MaterialID { get; set; }
        public string MaterialKey { get; set; }
        public string ColumnLabel { get; set; }
        public string DeterminationScore { get; set; }
        public string FieldID { get; set; }
        public string ImportLevel { get; set; }
        public int TestResultID { get; set; }
        public int ResultStatus { get; set; }
        public int TratiDetResultID { get; set; }
        public string TraitScore { get; set; }
        public int FlowType { get; set; }
    }
}
