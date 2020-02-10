using System;
using System.Threading.Tasks;
using Enza.UTM.BusinessAccess.Planning.Interfaces;
using Enza.UTM.DataAccess.Data.Planning.Interfaces;
using System.Data;
using Enza.UTM.Entities;
using System.Collections.Generic;
using System.Linq;
using Enza.UTM.Entities.Results;

namespace Enza.UTM.BusinessAccess.Planning.Services
{
    public class MasterDataService : IMasterDataService
    {
        readonly IMasterDataRepository repository;
        public MasterDataService(IMasterDataRepository repository)
        {
            this.repository = repository;
        }

        public async Task<IEnumerable<BreedingStation>> GetBreedingStationAsync()
        {
            return await repository.GetBreedingStationAsync();
        }

        public async Task<IEnumerable<Crop>> GetCropsAsync()
        {
            return await repository.GetCropsAsync();
        }
        
        public async Task<IEnumerable<MaterialTypeResult>> GetMaterialTypePerCropAsync(string crop)
        {
            return await repository.GetMaterialTypePerCropAsync(crop);
        }

        public async Task<IEnumerable<MaterialStateResult>> GetMaterialStateAsync()
        {
            return await repository.GetMaterialStateAsync();
        }

        public async Task<IEnumerable<MaterialTypeResult>> GetMaterialTypeAsync()
        {
            return await repository.GetMaterialTypeAsync();
        }

        public async Task<DataSet> GetReserveCapacityLookUp(IEnumerable<string> cropCodes)
        {
            return await repository.GetReserveCapacityLookUp(cropCodes);
        }

        public Task<PlanPeriod> GetCurrentPlanPeriodAsync()
        {
            return repository.GetCurrentPlanPeriodAsync();
        }

        public async Task<IEnumerable<PlanPeriod>> GetPlanPeriodsAsync(int? year)
        {
            var items = await repository.GetPlanPeriodsAsync(year);
            if (items.Any())
            {
                var currentPeriod = await repository.GetCurrentPlanPeriodAsync();
                if (currentPeriod != null)
                {
                    var item = items.FirstOrDefault(o => o.PeriodID == currentPeriod.PeriodID);
                    if (item != null)
                    {
                        item.Selected = true;
                    }
                }
            }
            return items;
        }

        public async Task<IEnumerable<TestType>> GetTestTypeAsync()
        {
            return await repository.GetTestTypeAsync();
        }

        public async Task<GetDisplayPeriodResult> GetDisplayPeriodAsync(DateTime args)
        {
            return await repository.GetDisplayPeriodAsync(args);
        }
    }
}
