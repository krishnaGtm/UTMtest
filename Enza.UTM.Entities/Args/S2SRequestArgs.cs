using Enza.UTM.Common.Attributes;

namespace Enza.UTM.Entities.Args
{
    public class S2SRequestArgs : ImportDataRequestArgs
    {
        //this is first level code which contains research group level id including cropcode from rgvariables from phenome
        public string FolderID { get; set; }
        public string CropID { get; set; }
        public string ObjectType { get; set; }
        public string GridID { get; set; }
        [SwaggerExclude]
        public string PositionStart { get; set; }
        public string CropCode { get; set; }
        public int CapacitySlotID { get; set; }
        public string CapacitySlotName { get; set; }
        public bool ForcedImport { get; set; }
        public int MaxPlants { get; set; }
        public string CordysStatus { get; set; }
        public string DH0Location { get; set; }
        public int AvailPlants { get; set; }
    }
    public class S2SCapacitySlotArgs
    {
        public string BreEzysAdministration { get; set; }
        public int? Year { get; set; }
        public string Crop { get; set; }
        public string ImportLevel { get; set; }

        /// <summary>
        /// value should be Seeds or Plants
        /// </summary>
        /// <Remarks>
        /// When we select import from list value should be Seeds and when we select plants value should be Plants
        ///</Remarks>
        [SwaggerExclude]
        public string Source { get; set; }
        public int? CapacitySlotID { get; set; }

    }
}
