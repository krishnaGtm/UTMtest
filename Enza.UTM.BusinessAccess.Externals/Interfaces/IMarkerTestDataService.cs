using Enza.UTM.Entities.Externals.Args;
using System.Data;
using System.Threading.Tasks;

namespace Enza.UTM.BusinessAccess.Externals.Interfaces
{
    public interface IMarkerTestDataService
    {
        Task<DataTable> GetMasterTestDataAsync(GetMarkerTestDataRequestArgs requestArgs);
    }
}
