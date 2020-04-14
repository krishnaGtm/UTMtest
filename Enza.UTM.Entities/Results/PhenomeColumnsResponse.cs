using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Enza.UTM.Entities.Results
{
    public class PhenomeColumnsResponse : PhenomeResponse
    {
        public List<Column> Columns { get; set; }

    }
    public class Column
    {
        //this property is equivalent to name property of column
        public string desc { get; set; }

        //this is equivalent to trait id
        public string variable_id { get; set; }

        //this is used to get data based for matching column
        public string id { get; set; }
        public string data_type { get; set; }
    }
    public class GermplmasColumnsAll:GermplasmColumn
    {
        public GermplmasColumnsAll()
        {
            All_Columns = new List<GermplasmColumn>();
        }
        public string Status { get; set; }
        public string Message { get; set; }
        public List<GermplasmColumn> All_Columns;
    }
    public class GermplasmColumn : Column
    {
        public GermplasmColumn()
        {
            properties = new List<GermplasmColumnProperty>();
        }
        public string desc { get; set; }
        public string col_num { get; set; }
        public string variable_id { get; set; }
        public List<GermplasmColumnProperty> properties { get; set; }
    }
    public class GermplasmColumnProperty
    {
        public string id { get; set; }
    }
    public class Row1
    {
        public int MyProperty { get; set; }
    }
}
