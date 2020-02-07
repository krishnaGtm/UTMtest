using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Enza.UTM.Entities.Results
{

    public class PhenomeDataResponse:PhenomeResponse
    {
        public PhenomeDataResponse()
        {
            Columns = new List<Column2>();
            Rows = new List<Row2>();
            Properties = new List<GridProperty2>();
        }
        public List<Column2> Columns { get; set; }    
        public List<Row2> Rows { get; set; }
        public List<GridProperty2> Properties { get; set; }
        
    }
    public class GridProperty2
    {
        public int Total_count { get; set; }
    }
    public class Column2
    {
        public Column2()
        {
            Properties = new List<Property2>();
        }
        public string  Name { get; set; }
        public List<Property2> Properties { get; set; }
    }
    public class Property2
    {
        //this is equivalent to GID.
        public string ID { get; set; }
    }
    public class Cell2
    {
        public string Value { get; set; }
    }
    public class Row2
    {
        public Row2()
        {
            Cells = new List<Cell2>();
            Properties = new List<Property2>();
        }
        public List<Cell2> Cells { get; set; }
        public List<Property2> Properties { get; set; }
    }
}
