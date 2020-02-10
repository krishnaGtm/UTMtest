using Enza.UTM.Common.Attributes;

namespace Enza.UTM.Entities.Args
{
    public class ThreeGBImportRequestArgs : ImportDataRequestArgs
    {
        //this is first level code which contains research group level id including cropcode from rgvariables from phenome
        public string FolderID { get; set; }
        public string CropID { get; set; }
        public string ObjectType { get; set; }
        public string GridID { get; set; }
        [SwaggerExclude]
        //public string PositionStart { get; set; }
        public string CropCode { get; set; }
        public string BrStationCode { get; set; }
        [SwaggerExclude]
        public string SyncCode { get; set; }
        [SwaggerExclude]
        public string CountryCode { get; set; }
        public int ThreeGBTaskID { get; set; }
        public bool ForcedImport { get; set; }
    }
}
