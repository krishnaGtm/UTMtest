using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using Enza.UTM.DataAccess.Interfaces;
using Enza.UTM.Entities.Externals.Args;

namespace Enza.UTM.DataAccess.Data.Externals.Interfaces
{
    public interface IDHRepository : IRepository<object>
    {
        Task StoreDH0Async(IEnumerable<StoreDH0RequestArgs> args);
    }
}
