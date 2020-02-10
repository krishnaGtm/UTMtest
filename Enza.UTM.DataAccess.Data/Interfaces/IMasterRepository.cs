using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using Enza.UTM.DataAccess.Interfaces;
using Enza.UTM.Entities;
using Enza.UTM.Entities.Args;

namespace Enza.UTM.DataAccess.Data.Interfaces
{
    public interface IMasterRepository : IRepository<object>
    {
        Task<IEnumerable<Crop>> GetCropAsync();
        Task<IEnumerable<TraitValueLookup>> GetTraitValuesAsync(string cropCode, int traitId);
        Task<IEnumerable<BreedingStation>> GetBreedingStationAsync();
        Task<IEnumerable<TestProtocol>> GetTestProtocolsAsync();
        Task<DataTable> GetCNTProcessesAsync();
        Task SaveCNTProcessAsync(IEnumerable<CNTProcessRequestArgs> items);

        Task<DataTable> GetCNTLabLocationsAsync();
        Task SaveCNTLabLocationsAsync(IEnumerable<CNTLabLocationRequestArgs> items);

        Task<DataTable> GetCNTStartMaterialsAsync();
        Task SaveCNTStartMaterialsAsync(IEnumerable<CNTStartMaterialRequestArgs> items);

        Task<DataTable> GetCNTTypesAsync();
        Task SaveCNTTypesAsync(IEnumerable<CNTTypeRequestArgs> items);
    }
}
