namespace Enza.UTM.Entities.Args
{
    public class SaveMaterialTypeTestProtocolsRequestArgs
    {
        public int? OldMaterialTypeID { get; set; }
        public int? OldTestProtocolID { get; set; }
        public string OldCropCode { get; set; }

        public int MaterialTypeID { get; set; }
        public int TestProtocolID { get; set; }
        public string CropCode { get; set; }
    }
}
