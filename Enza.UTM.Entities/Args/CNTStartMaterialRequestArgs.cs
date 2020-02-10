namespace Enza.UTM.Entities.Args
{
    public class CNTStartMaterialRequestArgs
    {
        public int? StartMaterialID { get; set; }
        public string StartMaterialName { get; set; }
        public bool Active { get; set; }
        public string Action { get; set; }
    }
}
