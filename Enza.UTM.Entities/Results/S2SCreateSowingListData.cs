namespace Enza.UTM.Entities.Results
{
    public class S2SCreateSowingListData
    {
        public string CropCode { get; set; }
        public int CapacitySlotID { get; set; }
        public string CapacitySlotName { get; set; }
        public string MasterNumber { get; set; }
        public string BreezysPKReference { get; set; }
        public int BreezysID { get; set; }
        public int BreezysRefCode { get; set; }
        public string BreedingStation { get; set; }
        public string BreEzysAdminstration { get; set; }
        public string DonorNumber { get; set; }
        public string Project { get; set; }
        public string PlantNumber { get; set; }
        //public bool Type { get; set; }
        //public bool Medium { get; set; }
        public int CrossingYear { get; set; }
        public int LotNumber { get; set; }
        public int NrOfSeeds { get; set; }
        public int NrOfPlannedTransplanted { get; set; }
        public int NrOfPlannedDHEmbryoRescueNett { get; set; }
        public int NrOfPlannedDHEmbryoRescueGross { get; set; }
        public bool DH0MakerTestNeeded { get; set; }
    }
}
