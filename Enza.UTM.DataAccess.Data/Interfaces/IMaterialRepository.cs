using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using Enza.UTM.DataAccess.Interfaces;
using Enza.UTM.Entities.Args;
using Enza.UTM.Entities.Results;

namespace Enza.UTM.DataAccess.Data.Interfaces
{
    public interface IMaterialRepository : IRepository<object>
    {
        Task<IEnumerable<MaterialLookupResult>> GetLookupAsync(MaterialLookupRequestArgs requestArgs);
        Task<DeleteMaterialResult> MarkDeadAsync(DeleteMaterialRequestArgs requestArgs);
        Task<IEnumerable<MaterialStateResult>> GetMaterialStateAsync();
        Task<IEnumerable<MaterialTypeResult>> GetMaterialTypeAsync();
        Task<bool> DeleteDeadMaterialAsync(DeleteMaterialRequestArgs requestArgs);
        Task<bool> ReplicateMaterial(ReplicateMaterialRequestArgs requestArgs);
        Task<bool> DeleteReplicateMaterialAsync(DeleteReplicateMaterialRequestArgs requestArgs);
        Task<DeleteMaterialResult> UndoDeadAsync(DeleteMaterialRequestArgs requestArgs);
        Task<bool> AddMaterialAsync(AddMaterialRequestArgs requestArgs);
        Task<DataWithMarkerResult> GetSelectedDataAsync(AddMaterialRequestArgs requestArgs);
    }
}
