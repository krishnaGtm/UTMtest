using System.Data;
using System.Threading.Tasks;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.DataAccess.Data.Interfaces;
using Enza.UTM.Entities.Args;

namespace Enza.UTM.BusinessAccess.Services
{
    public class MaterialTypeTestProtocolService : IMaterialTypeTestProtocolService
    {
        readonly IMaterialTypeTestProtocolRepository _repository;
        public MaterialTypeTestProtocolService(IMaterialTypeTestProtocolRepository repository)
        {
            _repository = repository;
        }
        public Task<DataTable> GetDataAsync(GetMaterialTypeTestProtocolsRequestArgs requestArgs)
        {
            return _repository.GetDataAsync(requestArgs);
        }

        public Task SaveDataAsync(SaveMaterialTypeTestProtocolsRequestArgs requestArgs)
        {
            return _repository.SaveDataAsync(requestArgs);
        }
    }
}
