using System.Collections.Generic;
using System.Threading.Tasks;
using Enza.UTM.Entities;
using Enza.UTM.Entities.Args;
using Enza.UTM.Entities.Results;

namespace Enza.UTM.BusinessAccess.Interfaces
{
    public interface IWellService
    {
        Task<IEnumerable<WellPosition>> GetLookupAsync(WellLookupRequestArgs request);
        Task<bool> AssignFixedPositionAsync(AssignFixedPositionRequestArgs request);
        Task<bool> ReOrderMaterialPositionAsync(ReOrderMaterialPositionRequestArgs request);
        Task<IEnumerable<WellTypeResult>> GetWellTypeAsync();
        Task<bool> UndoFixedPositionAsync(AssignFixedPositionRequestArgs args);
    }
}
