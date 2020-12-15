using System.Collections.Generic;
using System.Data;
using Enza.UTM.Common.Attributes;
using Enza.UTM.Entities.Args.Abstract;

namespace Enza.UTM.Entities.Args
{
    public class RDTSaveTraitDeterminationResultRequestArgs : PagedRequestArgs
    {
        [SwaggerExclude]
        public string Crops { get; set; }
        public RDTSaveTraitDeterminationResultRequestArgs()
        {
            Data = new List<RDTTraitDeterminationResultRDT>();
        }
        public string CropCode { get; set; }
        public List<RDTTraitDeterminationResultRDT> Data { get; set; }

        public DataTable ToTvp()
        {
            var dt = new DataTable("TVP_RDTTraitDeterminationResult");
            dt.Columns.Add("RDTTraitDetResultID", typeof(int));
            dt.Columns.Add("RelatioID", typeof(int));
            dt.Columns.Add("TraitResult");
            dt.Columns.Add("DetResult");
            dt.Columns.Add("MaterialStatus");
            dt.Columns.Add("MinPercent");
            dt.Columns.Add("MaxPercent");
            dt.Columns.Add("MappingCol");
            dt.Columns.Add("Action");

            foreach (var item in Data)
            {
                var dr = dt.NewRow();
                dr["RDTTraitDetResultID"] = item.ID;
                dr["RelatioID"] = item.RelationID;
                dr["TraitResult"] = item.TraitValue;
                dr["DetResult"] = item.DeterminationValue;
                dr["MaterialStatus"] = item.MaterialStatus;
                dr["MinPercent"] = item.MinPercent;
                dr["MaxPercent"] = item.MaxPercent;
                dr["MappingCol"] = item.MappingCol;
                dr["Action"] = item.Action;
                dt.Rows.Add(dr);
            }
            return dt;
        }
    }

    public class RDTTraitDeterminationResultRDT
    {
        public int ID { get; set; }
        public int RelationID { get; set; }
        public string TraitValue { get; set; }
        public string DeterminationValue { get; set; }
        public string MaterialStatus { get; set; }
        public decimal? MinPercent { get; set; }
        public decimal? MaxPercent { get; set; }
        public string MappingCol { get; set; }
        public string Action { get; set; }

        
    }
}
