using System.Collections.Generic;
using System.Threading.Tasks;
using Enza.UTM.DataAccess.Interfaces;
using Enza.UTM.Entities;
using Enza.UTM.Entities.Args;

namespace Enza.UTM.DataAccess.Data.Interfaces
{
    public interface IStatusRepository: IRepository<StatusLookup>
    {
        Task<IEnumerable<StatusLookup>> GetLookupAsync(string request);
    }
}
