using System.Collections.Generic;
using System.Data;
using Enza.UTM.Common.Attributes;
using Enza.UTM.Entities.Args.Abstract;

namespace Enza.UTM.Entities.Args
{
    public class SaveTraitDeterminationResultRequestArgs : PagedRequestArgs
    {
        [SwaggerExclude]
        public string Crops { get; set; }
        public SaveTraitDeterminationResultRequestArgs()
        {
            Data = new List<TraitDeterminationResult>();
        }
        public string CropCode { get; set; }
        public List<TraitDeterminationResult> Data { get; set; }

        public DataTable ToTvp()
        {
            var dt = new DataTable("TVP_TraitDeterminationResult");
            dt.Columns.Add("TraitDeterminationResultID", typeof(int));
            dt.Columns.Add("RelatioID", typeof(int));
            //dt.Columns.Add("DeterminationID", typeof(int));
            dt.Columns.Add("TraitResChar", typeof(string));
            dt.Columns.Add("DetResChar", typeof(string));
            dt.Columns.Add("Action", typeof(string));

            foreach (var item in Data)
            {
                var dr = dt.NewRow();
                dr["TraitDeterminationResultID"] = item.ID;
                dr["RelatioID"] = item.RelationID;
                //dr["DeterminationID"] = item.DeterminationID;
                dr["TraitResChar"] = item.TraitValue;
                dr["DetResChar"] = item.DeterminationValue;
                dr["Action"] = item.Action;
                dt.Rows.Add(dr);
            }
            return dt;
        }
    }

    public class TraitDeterminationResult
    {
        public int ID { get; set; }
        public int RelationID { get; set; }
        //public int DeterminationID { get; set; }
        public string TraitValue { get; set; }
        public string DeterminationValue { get; set; }
        public string Action { get; set; }
    }
}
