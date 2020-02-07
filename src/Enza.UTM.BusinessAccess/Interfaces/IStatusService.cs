using System.Collections.Generic;
using System.Threading.Tasks;
using Enza.UTM.Entities;
using Enza.UTM.Entities.Args;

namespace Enza.UTM.BusinessAccess.Interfaces
{
    public interface IStatusService
    {
        Task<IEnumerable<StatusLookup>> GetLookupAsync(string request);
    }
}
