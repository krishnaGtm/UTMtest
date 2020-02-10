using System.Collections.Generic;
using System.Threading.Tasks;
using Enza.UTM.DataAccess.Interfaces;
using Enza.UTM.Entities.Args;
using Enza.UTM.Entities.Results;
using Enza.UTM.Entities;

namespace Enza.UTM.DataAccess.Data.Interfaces
{
    public interface IDeterminationRepository : IRepository<object>
    {
        Task<IEnumerable<DeterminationResult>> GetDeterminationsAsync(DeterminationRequestArgs request);
        Task<Test> AssignDeterminationsAsync(AssignDeterminationRequestArgs request);
        Task<DataWithMarkerResult> GetDataWithDeterminationsAsync(DataWithMarkerRequestArgs request);
        Task<MaterialsWithMarkerResult> GetMaterialsWithDeterminationsAsync(MaterialsWithMarkerRequestArgs request);
        Task<IEnumerable<DeterminationResult>> GetDeterminationsForExternalTestsAsync(ExternalDeterminationRequestArgs requestArgs);
        Task<MaterialsWithMarkerResult> GetMaterialsWithDeterminationsForExternalTestAsync(MaterialsWithMarkerRequestArgs request);
    }
}
