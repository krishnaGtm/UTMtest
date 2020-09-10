using System.Collections.Generic;
using System.Threading.Tasks;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.DataAccess.Data.Interfaces;
using Enza.UTM.Entities.Results;
using Enza.UTM.Entities;
using Enza.UTM.Entities.Args;
using System.Data;

namespace Enza.UTM.BusinessAccess.Services
{
    public class MasterService : IMasterService
    {
        readonly IMasterRepository repository;
        public MasterService(IMasterRepository repository)
        {
            this.repository = repository;
        }

        public MasterService()
        {
        }

        public async Task<IEnumerable<Crop>> GetCropAsync()
        {
            return await repository.GetCropAsync();

        }

        public async Task<IEnumerable<TraitValueLookup>> GetTraitValuesAsync(string cropCode, int traitID)
        {
            return await repository.GetTraitValuesAsync(cropCode, traitID);
        }

        public async Task<IEnumerable<BreedingStation>> GetBreedingStationAsync()
        {
            return await repository.GetBreedingStationAsync();
        }

        public Task<IEnumerable<TestProtocol>> GetTestProtocolsAsync()
        {
            return repository.GetTestProtocolsAsync();
        }

        public Task<DataTable> GetCNTProcessesAsync()
        {
            return repository.GetCNTProcessesAsync();
        }

        public Task SaveCNTProcessAsync(IEnumerable<CNTProcessRequestArgs> items)
        {
            return repository.SaveCNTProcessAsync(items);
        }

        public Task<DataTable> GetCNTLabLocationsAsync()
        {
            return repository.GetCNTLabLocationsAsync();
        }

        public Task SaveCNTLabLocationsAsync(IEnumerable<CNTLabLocationRequestArgs> items)
        {
            return repository.SaveCNTLabLocationsAsync(items);
        }

        public Task<DataTable> GetCNTStartMaterialsAsync()
        {
            return repository.GetCNTStartMaterialsAsync();
        }

        public Task SaveCNTStartMaterialsAsync(IEnumerable<CNTStartMaterialRequestArgs> items)
        {
            return repository.SaveCNTStartMaterialsAsync(items);
        }

        public Task<DataTable> GetCNTTypesAsync()
        {
            return repository.GetCNTTypesAsync();
        }

        public Task SaveCNTTypesAsync(IEnumerable<CNTTypeRequestArgs> items)
        {
            return repository.SaveCNTTypesAsync(items);
        }

        public Task<IEnumerable<SiteLocation>> GetSitesAsync()
        {
            return repository.GetSitesAsync();
        }
    }
}
