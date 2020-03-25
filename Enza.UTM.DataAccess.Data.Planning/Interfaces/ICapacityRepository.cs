using System.Data;
using System.Threading.Tasks;
using Enza.UTM.DataAccess.Interfaces;
using Enza.UTM.Entities.Args;
using Enza.UTM.Entities.Results;

namespace Enza.UTM.DataAccess.Data.Planning.Interfaces
{
    public interface ICapacityRepository : IRepository<object>
    {
        Task<DataSet> GetCapacityAsync(int year);
        Task<bool> SaveCapacityAsync(SaveCapacityRequestArgs request);
        Task<ReserveCapacityResult> ReserveCapacityAsync(ReserveCapacityRequestArgs args);

        Task<DataSet> GetPlanApprovalListForLabAsync(int periodID);
        Task<bool> MoveSlotAsync(MoveSlotRequestArgs args);
        Task<bool> DeleteSlotAsync(DeleteSlotRequestArgs args);
    }
}
