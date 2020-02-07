using System.Collections.Generic;
using System.Data;

namespace Enza.UTM.Entities.Results
{
    public class PrintLabelResult
    {
        public bool Success { get; set; }
        public string Error { get; set; }
        public string PrinterName { get; set; }
    }
}
