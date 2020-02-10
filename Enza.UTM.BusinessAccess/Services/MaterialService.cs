using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.DataAccess.Data.Interfaces;
using Enza.UTM.Entities.Args;
using Enza.UTM.Entities.Results;

namespace Enza.UTM.BusinessAccess.Services
{
    public class MaterialService : IMaterialService
    {
        readonly IMaterialRepository repository;
        public MaterialService(IMaterialRepository repository)
        {
            this.repository = repository;
        }

        public async Task<bool> DeleteDeadMaterialAsync(DeleteMaterialRequestArgs requestArgs)
        {
            return await repository.DeleteDeadMaterialAsync(requestArgs);
        }
        public async Task<bool> ReplicateMaterial(ReplicateMaterialRequestArgs requestArgs)
        {
            return await repository.ReplicateMaterial(requestArgs);
        }

        public async Task<DeleteMaterialResult> MarkDeadAsync(DeleteMaterialRequestArgs requestArgs)
        {
            return await repository.MarkDeadAsync(requestArgs);
        }
        

        public async Task<IEnumerable<MaterialLookupResult>> GetLookupAsync(MaterialLookupRequestArgs requestArgs)
        {
            return await repository.GetLookupAsync(requestArgs);
        }

        public async Task<IEnumerable<MaterialStateResult>> GetMaterialStateAsync()
        {
            return await repository.GetMaterialStateAsync();
        }

        public async Task<IEnumerable<MaterialTypeResult>> GetMaterialTypeAsync()
        {
            return await repository.GetMaterialTypeAsync();
        }

        public async Task<bool> DeleteReplicateMaterialAsync(DeleteReplicateMaterialRequestArgs requestArgs)
        {
            return await repository.DeleteReplicateMaterialAsync(requestArgs);
        }

        public async Task<DeleteMaterialResult> UndoDeadAsync(DeleteMaterialRequestArgs requestArgs)
        {
            return await repository.UndoDeadAsync(requestArgs);
        }

        public async Task<bool> AddMaterialAsync(AddMaterialRequestArgs requestArgs)
        {
            return await repository.AddMaterialAsync(requestArgs);
        }

        public async Task<DataWithMarkerResult> GetSelectedDataAsync(AddMaterialRequestArgs requestArgs)
        {
            return await repository.GetSelectedDataAsync(requestArgs);
        }
    }
}
