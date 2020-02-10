using System.Collections.Generic;

namespace Enza.UTM.Entities.Results
{

    public class Plate
    {
        public int PlateID { get; set; }
        public string PlateName { get; set; }
        public string BarCode { get; set; }
        public int TotalColumns { get; set; }
        public string PlatePlanBarCode { get; set; }
        public string PlatePlanName { get; set; }
        public string FileTitle { get; set; }
        public string SlotName { get; set; }
        public List<Row> Rows { get; set; }
    }

    public class Row
    {
        public string RowID { get; set; }
        public List<Cell> Cells { get; set; }

    }
    public class Cell
    {
        public string MaterialKey { get; set; }
        public string BgColor { get; set; }
        public string FgColor { get; set; }
        public int Column { get; set; }
        public bool Broken { get; set; }
    }

    public class RawPlateData : Cell
    {
        public int PlateID { get; set; }
        public string PlateName { get; set; }
        public string Row { get; set; }
        public string FileTitle { get; set; }

    }

}
