using System.Collections.Generic;
using Enza.UTM.Entities.Externals.Args;
using System.Threading.Tasks;

namespace Enza.UTM.BusinessAccess.Externals.Interfaces
{
    public interface IDHService
    {
        Task StoreDH0Async(IEnumerable<StoreDH0RequestArgs> args);
    }
}
