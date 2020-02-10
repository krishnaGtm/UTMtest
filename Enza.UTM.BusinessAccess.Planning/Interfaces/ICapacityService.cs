using Enza.UTM.Entities;
using System.Data;
using System.Threading.Tasks;
using Enza.UTM.Entities.Args;
using Enza.UTM.Entities.Results;
using System.Collections.Generic;

namespace Enza.UTM.BusinessAccess.Planning.Interfaces
{
    public interface ICapacityService
    {
        Task<DataSet> GetCapacityAsync(int year);
        Task<bool> SaveCapacityAsync(SaveCapacityRequestArgs request);
        Task<ReserveCapacityResult> ReserveCapacityAsync(ReserveCapacityRequestArgs args);
        Task<DataSet> GetPlanApprovalListForLabAsync(int periodID);
        Task<bool> MoveSlotAsync(MoveSlotRequestArgs args);
        Task<bool> DeleteSlotAsync(int SlotID);
    }
}
