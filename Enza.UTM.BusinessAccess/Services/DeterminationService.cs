using System.Collections.Generic;
using System.Threading.Tasks;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.DataAccess.Data.Interfaces;
using Enza.UTM.Entities.Args;
using Enza.UTM.Entities.Results;
using Enza.UTM.Entities;

namespace Enza.UTM.BusinessAccess.Services
{
    public class DeterminationService : IDeterminationService
    {
        readonly IDeterminationRepository repository;
        public DeterminationService(IDeterminationRepository repository)
        {
            this.repository = repository;
        }
        public async Task<IEnumerable<DeterminationResult>> GetDeterminationsAsync(DeterminationRequestArgs request)
        {
            request.Validate();
            return await repository.GetDeterminationsAsync(request);
        }
        public async Task<Test> AssignDeterminationsAsync(AssignDeterminationRequestArgs request)
        {
            return await repository.AssignDeterminationsAsync(request);
        }
        public async Task<DataWithMarkerResult> GetDataWithDeterminationsAsync(DataWithMarkerRequestArgs request)
        {
            request.Validate();
            return await repository.GetDataWithDeterminationsAsync(request);
        }

        public async Task<MaterialsWithMarkerResult> GetMaterialsWithDeterminationsAsync(MaterialsWithMarkerRequestArgs request)
        {
            request.Validate();
            return await repository.GetMaterialsWithDeterminationsAsync(request);
        }

        public Task<IEnumerable<DeterminationResult>> GetDeterminationsForExternalTestsAsync(ExternalDeterminationRequestArgs requestArgs)
        {
            requestArgs.Validate();
            return repository.GetDeterminationsForExternalTestsAsync(requestArgs);
        }

        public async Task<MaterialsWithMarkerResult> GetMaterialsWithDeterminationsForExternalTestAsync(MaterialsWithMarkerRequestArgs request)
        {
            request.Validate();
            return await repository.GetMaterialsWithDeterminationsForExternalTestAsync(request);
        }
    }
}
