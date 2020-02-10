using System.Data;
using System.Collections.Generic;

namespace Enza.UTM.Entities.Results
{
    public class PhenoneImportDataResult
    {
        public PhenoneImportDataResult()
        {
            Errors = new List<string>();
            Warnings = new List<string>();
        }
        public string CropCode { get; set; }
        public string BrStationCode { get; set; }
        public string SyncCode { get; set; }
        public string CountryCode { get; set; }
        public DataTable TVPColumns { get; set; }
        public DataTable TVPRows { get; set; }
        public DataTable TVPCells { get; set; }
        public DataTable TVPList { get; set; }
        public List<string> Errors { get; set; }
        public List<string> Warnings { get; set; }
        public int Total { get; set; }
        public ExcelData DataResult { get; set; }
    }
}
