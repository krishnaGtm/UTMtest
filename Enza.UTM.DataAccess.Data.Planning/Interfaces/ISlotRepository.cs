using System.Data;
using System.Threading.Tasks;
using Enza.UTM.DataAccess.Interfaces;
using Enza.UTM.Entities;
using Enza.UTM.Entities.Args;
using Enza.UTM.Entities.Results;

namespace Enza.UTM.DataAccess.Data.Planning.Interfaces
{
    public interface ISlotRepository : IRepository<object>
    {
        Task<GetAvailPlatesTestsResult> GetAvailPlatesTestsAsync(GetAvailPlatesTestsRequestArgs request);
        Task<SlotLookUp> GetSlotDataAsync(int id);
        Task<EmailDataArgs> UpdateSlotPeriodAsync(UpdateSlotPeriodRequestArgs request);
        Task<EmailDataArgs> ApproveSlotAsync(int SlotID);
        Task<EmailDataArgs> DenySlotAsync(int SlotID);
        Task<DataTable> GetPlannedOverviewAsync(int year, int? periodID);
        Task<BreedingOverviewResult> GetBreedingOverviewAsync(BreedingOverviewRequestArgs requestArgs);
        Task<EditSlotResult> EditSlotAsync(EditSlotRequestArgs args);
        Task<DataTable> GetApprovedSlotsAsync(string userName, string slotName, string crops);
    }
}
