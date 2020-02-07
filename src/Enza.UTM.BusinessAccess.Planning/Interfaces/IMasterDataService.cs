using System;
using Enza.UTM.Entities;
using Enza.UTM.Entities.Results;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;

namespace Enza.UTM.BusinessAccess.Planning.Interfaces
{
    public interface IMasterDataService
    {
        Task<IEnumerable<BreedingStation>> GetBreedingStationAsync();
        Task<IEnumerable<Crop>> GetCropsAsync();
        Task<IEnumerable<MaterialTypeResult>> GetMaterialTypeAsync();
        Task<IEnumerable<MaterialTypeResult>> GetMaterialTypePerCropAsync(string crop);
        Task<IEnumerable<MaterialStateResult>> GetMaterialStateAsync();
        Task<IEnumerable<TestType>> GetTestTypeAsync();
        Task<DataSet> GetReserveCapacityLookUp(IEnumerable<string> cropCodes);
        Task<PlanPeriod> GetCurrentPlanPeriodAsync();
        Task<IEnumerable<PlanPeriod>> GetPlanPeriodsAsync(int? year);
        Task<GetDisplayPeriodResult> GetDisplayPeriodAsync(DateTime request);
    }
}
