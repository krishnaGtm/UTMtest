using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Enza.UTM.Entities.Results
{
    public class PhenomeResponse
    {
        public string Message { get; set; }
        public string Status { get; set; }
        public bool Success
        {
            get
            {
                return string.CompareOrdinal(Status, "1") == 0;
            }
        }
    }
}
