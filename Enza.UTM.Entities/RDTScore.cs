namespace Enza.UTM.Entities
{
    public class RDTScore
    {
        public int TestID { get; set; }
        public int? ObservationID { get; set; }
        public string MaterialKey { get; set; }
        public string ColumnLabel { get; set; }
        public string Score { get; set; }
        public string FieldID { get; set; }
        public string ImportLevel { get; set; }
    }
}
