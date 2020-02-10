using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using Enza.UTM.DataAccess.Interfaces;
using Enza.UTM.Entities;
using Enza.UTM.Entities.Args;
using Enza.UTM.Entities.Results;

namespace Enza.UTM.DataAccess.Data.Planning.Interfaces
{
    public interface IMasterDataRepository : IRepository<object>
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
