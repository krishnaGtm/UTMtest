using System.Data;
using System.Threading.Tasks;
using Enza.UTM.Entities.Args;

namespace Enza.UTM.BusinessAccess.Interfaces
{
    public interface IMaterialTypeTestProtocolService
    {
        Task<DataTable> GetDataAsync(GetMaterialTypeTestProtocolsRequestArgs requestArgs);
        Task SaveDataAsync(SaveMaterialTypeTestProtocolsRequestArgs requestArgs);
    }
}
