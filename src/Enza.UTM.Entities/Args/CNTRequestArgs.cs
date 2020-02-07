using Enza.UTM.Common.Attributes;

namespace Enza.UTM.Entities.Args
{
    public class CNTRequestArgs
    {
        public int TestTypeID { get; set; }
        public int TestID { get; set; }
        public string TestName { get; set; }
        public string FilePath { get; set; }
        public string Source { get; set; }
        public string ObjectID { get; set; }
        public string ImportLevel { get; set; }
        //this is first level code which contains research group level id including cropcode from rgvariables from phenome
        public string FolderID { get; set; }
        public string CropID { get; set; }
        public string ObjectType { get; set; }
        public string GridID { get; set; }
        public string CropCode { get; set; }
        public bool ForcedImport { get; set; }
    }    
}
