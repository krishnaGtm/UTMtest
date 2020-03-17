using System.Threading.Tasks;
using Enza.UTM.BusinessAccess.Planning.Interfaces;
using Enza.UTM.DataAccess.Data.Planning.Interfaces;
using System.Data;
using Enza.UTM.Entities.Args;
using Enza.UTM.Entities.Results;

namespace Enza.UTM.BusinessAccess.Planning.Services
{
    public class CapacityService : ICapacityService
    {
        readonly ICapacityRepository repository;
        readonly ISlotService slotService;
        public CapacityService(ICapacityRepository repository, ISlotService slotService )
        {
            this.repository = repository;
            this.slotService = slotService;
        }

        public async Task<DataSet> GetCapacityAsync(int year)
        {
            return await repository.GetCapacityAsync(year);
        }

        public async Task<ReserveCapacityResult> ReserveCapacityAsync(ReserveCapacityRequestArgs args)
        {
            return await repository.ReserveCapacityAsync(args);
        }

        public Task<DataSet> GetPlanApprovalListForLabAsync(int periodID)
        {
            return repository.GetPlanApprovalListForLabAsync(periodID);
        }

        public async Task<bool> SaveCapacityAsync(SaveCapacityRequestArgs request)
        {
            return await repository.SaveCapacityAsync(request);
        }

        public async Task<bool> MoveSlotAsync(MoveSlotRequestArgs args)
        {
            //this method move slot to another week and update capacity if it is not sufficient also email notification is sent to requested user.
            var resp = await slotService.UpdateSlotPeriodAsync(new UpdateSlotPeriodRequestArgs
            {
                SlotID = args.SlotID,
                ExpectedDate = args.ExpectedDate,
                PlannedDate = args.PlannedDate,
                AllowOverride = true
            });
            
            //this method should be called if requesting user is breeder that do not have access to update capacity
            //for not it is not called
            //var data = await repository.MoveSlotAsync(args);
            return true;
        }

        public async Task<bool> DeleteSlotAsync(DeleteSlotRequestArgs args)
        {
            return await repository.DeleteSlotAsync(args);
        }

    }
}
