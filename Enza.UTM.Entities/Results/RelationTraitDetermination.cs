using Enza.UTM.Common.Attributes;

namespace Enza.UTM.Entities.Results
{
    public class RelationTraitDetermination
    {
        public int RelationID { get; set; }
        public string CropCode { get; set; } 
        public int TraitID { get; set; }
        public int DeterminationID { get; set; }
        public string Source { get; set; }
        public string TraitLabel { get; set; }
        public string DeterminationName { get; set; }
        public string DeterminationAlias { get; set; }
        public string Status { get; set; }
        [SwaggerExclude]
        public int TotalRows { get; set; }
    }
}
