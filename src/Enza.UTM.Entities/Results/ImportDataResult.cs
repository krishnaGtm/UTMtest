using System.Collections.Generic;

namespace Enza.UTM.Entities.Results
{
    public class ImportDataResult
    {
        public ImportDataResult()
        {
            Errors = new List<string>();
        }
        public bool Success
        {
            get
            {
                return Errors.Count <= 0;
            }
        }
        public List<string> Errors { get; set; }
    }
}