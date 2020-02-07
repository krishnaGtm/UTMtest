using System.Collections.Generic;
using System.Data;
using System.Linq;
using Enza.UTM.Entities.Args.Abstract;

namespace Enza.UTM.Entities.Args
{
    public class AddMaterialRequestArgs : PagedRequestArgs
    {
        public AddMaterialRequestArgs()
        {
            MaterialSelected = new List<Material>();
        }        
        public int TestID { get; set; }
        public List<Material> MaterialSelected { get; set; }
        public DataTable ToTVP()
        {
            var dt = new DataTable("TVP_3GBMaterial");            
            dt.Columns.Add("MaterialID", typeof(string));
            dt.Columns.Add("Selected", typeof(bool));
            foreach (var item in MaterialSelected)
            {
                var dr = dt.NewRow();
                dr["MaterialID"] = item.MaterialKey;
                dr["Selected"] = item.Selected;
                dt.Rows.Add(dr);
            }
            return dt;
        }

        public string ToColumnsString()
        {
            var col = string.Join(", ", Filter.Select(x => $"'{x.Name}'").ToArray());
            return col;
        }

        public class Material
        {
            public int MaterialKey { get; set; }
            public bool Selected { get; set; }
        }
    }
}
