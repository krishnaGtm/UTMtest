using System.Data;
using System.Threading.Tasks;
using Enza.UTM.DataAccess.Interfaces;
using Enza.UTM.Entities.Externals.Args;

namespace Enza.UTM.DataAccess.Data.Externals.Interfaces
{
    public interface IMarkerTestDataRepository : IRepository<object>
    {
        Task<DataTable> GetMasterTestDataAsync(GetMarkerTestDataRequestArgs requestArgs);
    }
}
