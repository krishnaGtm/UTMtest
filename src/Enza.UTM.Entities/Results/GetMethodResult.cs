using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Enza.UTM.Entities.Results
{
    public class GetMethodResult: PhenomeResponse
    {
        public List<ComboValue> Combo { get; set; }

    }
    public class ComboValue
    {
        public string Label { get; set; }
        public string  Value { get; set; }
    }
}
