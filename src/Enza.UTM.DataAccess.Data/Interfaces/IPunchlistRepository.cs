using System.Collections.Generic;
using System.Threading.Tasks;
using Enza.UTM.DataAccess.Interfaces;
using Enza.UTM.Entities.Results;

namespace Enza.UTM.DataAccess.Data.Interfaces
{
    public interface IPunchlistRepository : IRepository<object>
    {
        Task<IEnumerable<Plate>> GetPunchlistAsync(int testID);
    }
}
