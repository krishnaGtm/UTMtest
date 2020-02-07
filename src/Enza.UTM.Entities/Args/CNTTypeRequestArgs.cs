namespace Enza.UTM.Entities.Args
{
    public class CNTTypeRequestArgs
    {
        public int? TypeID { get; set; }
        public string TypeName { get; set; }
        public bool Active { get; set; }
        public string Action { get; set; }
    }
}
