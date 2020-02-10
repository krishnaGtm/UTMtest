namespace Enza.UTM.Entities.Args
{
    public class GetAvailPlatesTestsRequestArgs
    {
        public int MaterialTypeID { get; set; }
        public string CropCode { get; set; }
        public bool Isolated { get; set; }
        public string PlannedDate { get; set; }
    }
}
