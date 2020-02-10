namespace Enza.UTM.Entities.Args
{
    public class CNTLabLocationRequestArgs
    {
        public int? LabLocationID { get; set; }
        public string LabLocationName { get; set; }
        public bool Active { get; set; }
        public string Action { get; set; }
    }
}
