using System.Collections.Generic;
using System.Data;

namespace Enza.UTM.Entities.Results
{
    public class ExcelDataResult
    {
        public ExcelDataResult()
        {
            Errors = new List<string>();
            Warnings = new List<string>();
        }
        public bool Success { get; set; }
        public int Total { get; set; }
        public ExcelData DataResult { get; set; }
        public List<string> Errors { get; set; }
        public List<string> Warnings { get; set; }

    }
    public class ExcelData
    {
        public ExcelData()
        {
            Columns = new DataTable();
            Data = new DataTable();
        }
        public DataTable Columns { get; set; }
        public DataTable Data { get; set; }
    }
}
