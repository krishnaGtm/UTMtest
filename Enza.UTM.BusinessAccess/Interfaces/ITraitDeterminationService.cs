using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using Enza.UTM.Entities.Results;
using Enza.UTM.Entities.Args;
using Enza.UTM.Entities;

namespace Enza.UTM.BusinessAccess.Interfaces
{
    public interface ITraitDeterminationService
    {
        Task<IEnumerable<TraitResult>> GetTraitsAndDeterminationAsync(string traitName, string cropCode, string source);
        Task<IEnumerable<DeterminationResult>> GetDeterminationsAsync(string determinationName, string cropCode);
        Task<IEnumerable<RelationTraitDetermination>> GetRelationTraitDeterminationAsync(RelationTraitDeterminationRequestArgs args);
        Task<DataTable> GetTraitDeterminationResultAsync(TraitDeterminationResultRequestArgs requestArgs);
        Task<IEnumerable<RelationTraitDetermination>> SaveRelationTraitMaterialDetermination(SaveTraitDeterminationRelationRequestArgs args);
        Task<DataTable> SaveTraitDeterminationResultAsync(SaveTraitDeterminationResultRequestArgs requestArgs);
        Task<IEnumerable<TraitValueLookup>> GetTraitListOfValuesAsync(int cropTraitID);
        Task<IEnumerable<Crop>> GetCropAsync(List<string> crops);
    }
}
