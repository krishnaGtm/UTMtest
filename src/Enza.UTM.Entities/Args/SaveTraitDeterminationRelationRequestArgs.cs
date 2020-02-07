using System.Collections.Generic;
using System.Data;
using System.Linq;
using Enza.UTM.Common.Attributes;
using Enza.UTM.Entities.Args.Abstract;

namespace Enza.UTM.Entities.Args
{
    public class SaveTraitDeterminationRelationRequestArgs : PagedRequestArgs
    {
        [SwaggerExclude]
        public string Crops { get; set; }
        public SaveTraitDeterminationRelationRequestArgs()
        {
            RelationTraitDetermination = new List<TraitDeterminationRelation>();
        }
        public List<TraitDeterminationRelation> RelationTraitDetermination { get; set; }
        //public string Source { get; set; }

        public class TraitDeterminationRelation
        {
            public int RelationID { get; set; }
            public int TraitID { get; set; }
            public string TraitName { get; set; }
            public int DeterminationID { get; set; }
            public string Source { get; set; }
            public string Action { get; set; }
        }
        public DataTable ToRelationTraitDeterminationTVP()
        {
            var dt = new DataTable("TVP_RelationTraitDetermination");
            dt.Columns.Add("RelationID", typeof(int));
            dt.Columns.Add("TraitID", typeof(int));
            dt.Columns.Add("TraitName", typeof(string));
            dt.Columns.Add("DeterminationID", typeof(int));
            dt.Columns.Add("Source", typeof(string));
            dt.Columns.Add("Action", typeof(string));
            foreach (var item in RelationTraitDetermination)
            {
                var dr = dt.NewRow();
                dr["RelationID"] = item.RelationID;
                dr["TraitID"] = item.TraitID;
                dr["TraitName"] = item.TraitName;
                dr["DeterminationID"] = item.DeterminationID;
                dr["Source"] = item.Source;
                dr["Action"] = item.Action;
                dt.Rows.Add(dr);
            }
            return dt;
        }
    }
}
