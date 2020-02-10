using System.Collections.Generic;
using System.Threading.Tasks;
using Enza.UTM.DataAccess.Interfaces;
using Enza.UTM.Entities;
using Enza.UTM.Entities.Args;
using Enza.UTM.Entities.Results;

namespace Enza.UTM.DataAccess.Data.Interfaces
{
    public interface IWellRepository : IRepository<WellPosition>
    {
        Task<IEnumerable<WellPosition>> GetLookupAsync(WellLookupRequestArgs request);
        Task<bool> AssignFixedPosition(AssignFixedPositionRequestArgs request);
        Task<bool> ReOrderMaterialPositionAsync(ReOrderMaterialPositionRequestArgs request);
        Task<IEnumerable<WellTypeResult>> GetWellTypeAsync();
        Task<bool> UndoFixedPositionAsync(AssignFixedPositionRequestArgs request);
    }
}
