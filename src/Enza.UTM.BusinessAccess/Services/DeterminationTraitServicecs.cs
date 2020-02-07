using System.Threading.Tasks;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.DataAccess.Data.Interfaces;
using System.Collections.Generic;
using Enza.UTM.Entities.Results;

namespace Enza.UTM.BusinessAccess.Services
{
    public class DeterminationTraitServicecs : IDeterminationTraitService
    {
        readonly IDeterminationTraitRepository repository;
        public DeterminationTraitServicecs(IDeterminationTraitRepository repository)
        {
            this.repository = repository;
        }

        public async Task<IEnumerable<DeterminationResult>> GetDeterminationsAsync(string determinationName)
        {
            return await repository.GetDeterminationsAsync(determinationName);
        }

        public async Task<IEnumerable<TraitResult>> GetTraitsAsync(string traitName)
        {
            return await repository.GetTraitsAsync(traitName);
        }
    }
}
