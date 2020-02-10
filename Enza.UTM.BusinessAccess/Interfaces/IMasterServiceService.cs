using System.Collections.Generic;
using System.Threading.Tasks;
using Enza.UTM.Entities.Args;
using Enza.UTM.Entities.Results;
using Enza.UTM.Entities;

namespace Enza.UTM.BusinessAccess.Interfaces
{
    public interface IMasterService
    {
        Task<IEnumerable<Crop>> GetCropAsync();
        Task<IEnumerable<TraitValueLookup>> GetTraitValuesAsync(string cropCode, int traitID);
        Task<IEnumerable<BreedingStation>> GetBreedingStationAsync();
    }
}
