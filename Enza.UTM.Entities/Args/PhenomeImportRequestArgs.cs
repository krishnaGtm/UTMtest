using Enza.UTM.Common.Attributes;
using System;

namespace Enza.UTM.Entities.Args
{
    public class PhenomeImportRequestArgs : ImportDataRequestArgs
    {
        //this is first level code which contains research group level id including cropcode from rgvariables from phenome
        public string CropID { get; set; }
        public string ObjectType { get; set; }
        public string GridID { get; set; }
        [SwaggerExclude]
        public string PositionStart { get; set; }

        //this is third level tree which contains bo variables like breeding staion and synccode
        public string FolderID { get; set; }
        public bool ForcedImport { get; set; }

    }
}
