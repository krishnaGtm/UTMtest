using System.Data;
using System.Threading.Tasks;
using Enza.UTM.Entities;
using Enza.UTM.Entities.Args;
using Enza.UTM.Entities.Results;

namespace Enza.UTM.BusinessAccess.Planning.Interfaces
{
    public interface ISlotService
    {
        Task<GetAvailPlatesTestsResult> GetAvailPlatesTestsAsync(GetAvailPlatesTestsRequestArgs request);
        Task<SlotLookUp> GetSlotDataAsync(int id);
        Task<SlotApprovalResult> UpdateSlotPeriodAsync(UpdateSlotPeriodRequestArgs request);
        Task<SlotApprovalResult> ApproveSlotAsync(ApproveSlotRequestArgs requestArgs);
        Task<SlotApprovalResult> DenySlotAsync(int SlotID);
        Task<DataTable> GetPlannedOverviewAsync(int year, int? periodID);
        Task<BreedingOverviewResult> GetBreedingOverviewAsync(BreedingOverviewRequestArgs requestArgs);
        Task<SlotApprovalResult> EditSlotAsync(EditSlotRequestArgs args);
        Task<DataTable> GetApprovedSlotsAsync(string userName, string slotName, string crops);
    }
}
