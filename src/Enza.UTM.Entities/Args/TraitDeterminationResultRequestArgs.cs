using System.Collections.Generic;
using System.Data;
using System.Linq;
using Enza.UTM.Common.Attributes;
using Enza.UTM.Entities.Args.Abstract;

namespace Enza.UTM.Entities.Args
{
    public class TraitDeterminationResultRequestArgs : PagedRequestArgs
    {
        [SwaggerExclude]
        public string Crops { get; set; }
    }
}
