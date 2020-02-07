using System.Data;
using System.Threading.Tasks;
using Enza.UTM.DataAccess.Interfaces;
using Enza.UTM.Entities;
using Enza.UTM.Entities.Args;

namespace Enza.UTM.DataAccess.Data.Interfaces
{
    public interface IMaterialTypeTestProtocolRepository : IRepository<TestProtocol>
    {
        Task<DataTable> GetDataAsync(GetMaterialTypeTestProtocolsRequestArgs requestArgs);
        Task SaveDataAsync(SaveMaterialTypeTestProtocolsRequestArgs requestArgs);
    }
}
