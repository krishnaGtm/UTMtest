namespace Enza.UTM.Entities.Args
{
    public class CNTProcessRequestArgs
    {
        public int? ProcessID { get; set; }
        public string ProcessName { get; set; }
        public bool Active { get; set; }
        public string Action { get; set; }
    }
}
