namespace Enza.UTM.Entities.Results
{
    public class TraitResult
    {        
        public int CropTraitID { get; set; }
        public string TraitName { get; set; }
        public string TraitDescription { get; set; }
        public string CropCode { get; set; }
        public bool ListOfValues { get; set; }
        public int RelationID { get; set; }
        public int DeterminationID { get; set; }
        public string DeterminatioName { get; set; }
        public string DeterminationAlias { get; set; }

    }
}
