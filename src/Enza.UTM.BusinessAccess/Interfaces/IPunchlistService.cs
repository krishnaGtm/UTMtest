using System.Collections.Generic;
using System.Threading.Tasks;
using Enza.UTM.Entities.Results;

namespace Enza.UTM.BusinessAccess.Interfaces
{
    public interface IPunchlistService
    {
        Task<IEnumerable<Plate>> GetPunchlistAsync(int testID);
    }
}
