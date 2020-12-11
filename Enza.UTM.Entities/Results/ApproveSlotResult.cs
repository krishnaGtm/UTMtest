using System.Collections.Generic;

namespace Enza.UTM.Entities.Results
{
    public class ApproveSlotResult: EmailDataArgs
    {
        public bool Success { get; set; }
        public string Message { get; set; }

    }
    
}
