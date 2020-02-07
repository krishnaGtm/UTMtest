using System.Collections.Generic;
using System.Data;

namespace Enza.UTM.Entities.Results
{
    public class ExternalTestExportDataResult
    {
        public ExternalTestExportDataResult()
        {
            Columns = new List<ExportColumnInfo>();
        }
        public DataTable Data { get; set; }
        public List<ExportColumnInfo> Columns { get; set; }
    }

    public class ExportColumnInfo
    {
        public string ColumnID { get; set; }
        public string ColumnLabel { get; set; }
    }
}
