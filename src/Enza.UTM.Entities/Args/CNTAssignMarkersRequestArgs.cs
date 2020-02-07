using Enza.UTM.Entities.Args.Abstract;
using System.Collections.Generic;

namespace Enza.UTM.Entities.Args
{
    public class CNTAssignMarkersRequestArgs : FilteredRequestArgs
    {
        public CNTAssignMarkersRequestArgs()
        {
            Determinations = new List<int>();
            RowIDs = new List<int>();
        }
        public int TestID { get; set; }
        /// <summary>
        /// Comma separated list of determination id
        /// </summary>
        public List<int> Determinations { get; set; }
        public List<int> RowIDs { get; set; }
    }
}
