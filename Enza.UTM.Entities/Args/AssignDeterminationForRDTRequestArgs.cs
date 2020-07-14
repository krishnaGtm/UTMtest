using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using Enza.UTM.Entities.Args.Abstract;

namespace Enza.UTM.Entities.Args
{
    public class AssignDeterminationForRDTRequestArgs : PagedRequestArgs
    {
        public AssignDeterminationForRDTRequestArgs()
        {
            MaterialWithMarkerAndExpectedDate = new List<DeterminationWithExpectedDate>();
            PropertyValue = new List<RDTProperty>();
            Determinations = new List<int>();
        }        
        public int TestTypeID { get; set; }
        public int TestID { get; set; }
        public List<DeterminationWithExpectedDate> MaterialWithMarkerAndExpectedDate { get; set; }
        public List<RDTProperty> PropertyValue { get; set; }
        public List<int> Determinations { get; set; }
        public DataTable ToTVPTestMaterialDetermation()
        {
            var dt = new DataTable("TVP_TMD");            
            dt.Columns.Add("MaterialID", typeof(int));
            dt.Columns.Add("DeterminationID", typeof(int));
            dt.Columns.Add("Selected");
            dt.Columns.Add("ExpectedDate", typeof(DateTime));
            foreach (var item in MaterialWithMarkerAndExpectedDate)
            {
                var dr = dt.NewRow();
                dr["MaterialID"] = item.MaterialID;
                dr["DeterminationID"] = item.DeterminationID;
                dr["Selected"] = item.Selected;
                dr["ExpectedDate"] = item.ExpectedDate;
                dt.Rows.Add(dr);
            }
            return dt;
        }
        public DataTable ToTVPDeterminations()
        {
            var dt = new DataTable("TVP_Determinations");
            dt.Columns.Add("DeterminationID", typeof(int));
            foreach (var _item in Determinations)
            {
                var dr = dt.NewRow();
                dr["DeterminationID"] = _item;
                dt.Rows.Add(dr);
            }
            return dt;
        }
        public DataTable ToTVPPropertyValue()
        {
            var dt = new DataTable("TVP_RDTPropertyValue");
            dt.Columns.Add("MaterialID");
            dt.Columns.Add("key");
            dt.Columns.Add("Value");
            foreach(var _item in PropertyValue)
            {
                var dr = dt.NewRow();
                dr["MaterialID"] = _item.MaterialID;
                dr["Key"] = _item.Key;
                dr["Value"] = _item.Value;
                dt.Rows.Add(dr);
            }
            return dt;
        }

        public string ToColumnsString()
        {
            var col = string.Join(", ", Filter.Select(x => $"'{x.Name}'").ToArray());
            return col;
        }
    }
    public class DeterminationWithExpectedDate
    {
        public int MaterialID { get; set; }
        public int DeterminationID { get; set; }
        public bool? Selected { get; set; }
        public DateTime? ExpectedDate { get; set; }
    }
    public class RDTProperty
    {
        public int MaterialID { get; set; }
        public string Key { get; set; }
        public string Value { get; set; }
    }
}
