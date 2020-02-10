using Enza.UTM.DataAccess.Abstract;
using Enza.UTM.DataAccess.Interfaces;
using Enza.UTM.DataAccess.Data.Planning.Interfaces;
using System;
using System.Data;
using System.Threading.Tasks;
using Enza.UTM.Entities;
using System.Collections.Generic;
using System.Linq;
using Enza.UTM.Entities.Results;
using Enza.UTM.Common.Extensions;

namespace Enza.UTM.DataAccess.Data.Planning.Repositories
{
    public class MasterDataRepository : Repository<object>, IMasterDataRepository
    {
        private readonly IUserContext userContext;
        public MasterDataRepository(IDatabase dbContext, IUserContext userContext) : base(dbContext)
        {
            this.userContext = userContext;
        }

        public async Task<IEnumerable<BreedingStation>> GetBreedingStationAsync()
        {
            return await DbContext.ExecuteReaderAsync(DataConstants.PR_PLAN_GET_BREEDINGSTATION_LOOKUP, CommandType.StoredProcedure, reader =>
             new BreedingStation
             {
                 BreedingStationCode = reader.Get<string>(0),
                 BreedingStationName = reader.Get<string>(1),

             });

        }

        public async Task<IEnumerable<Crop>> GetCropsAsync()
        {
            return await DbContext.ExecuteReaderAsync(DataConstants.PR_PLAN_GET_CROP_LOOKUP, CommandType.StoredProcedure, reader =>
             new Crop
             {
                 CropCode = reader.Get<string>(0),
                 CropName = reader.Get<string>(1),
             });

        }

        public async Task<IEnumerable<MaterialTypeResult>> GetMaterialTypeAsync()
        {
            return await DbContext.ExecuteReaderAsync(DataConstants.PR_PLAN_GET_MATERIALTYPE_LOOKUP, CommandType.StoredProcedure, reader =>
             new MaterialTypeResult
             {
                 MaterialTypeID = reader.Get<int>(0),
                 MaterialTypeCode = reader.Get<string>(1),
                 MaterialTypeDescription = reader.Get<string>(2),
             });

        }

        public async Task<IEnumerable<MaterialTypeResult>> GetMaterialTypePerCropAsync(string crop)
        {
            return await DbContext.ExecuteReaderAsync(DataConstants.PR_PLAN_GET_MATERIALTYPEPERCROP_LOOKUP, CommandType.StoredProcedure,
                args =>
                {
                    args.Add("@CropCode", crop);
                }, reader =>
                    new MaterialTypeResult
                    {
                        MaterialTypeID = reader.Get<int>(0),
                        MaterialTypeCode = reader.Get<string>(1),
                        MaterialTypeDescription = reader.Get<string>(2),
                    });
        }

        public async Task<IEnumerable<MaterialStateResult>> GetMaterialStateAsync()
        {
            return await DbContext.ExecuteReaderAsync(DataConstants.PR_PLAN_GET_MATERIALSTATE_LOOKUP, CommandType.StoredProcedure, reader =>
             new MaterialStateResult
             {
                 MaterialStateID = reader.Get<int>(0),
                 MaterialStateCode = reader.Get<string>(1),
                 MaterialStateDescription = reader.Get<string>(2),
             });

        }
        public async Task<IEnumerable<TestType>> GetTestTypeAsync()
        {
            return await DbContext.ExecuteReaderAsync(DataConstants.PR_PLAN_GETTESTTYPE_LOOKUP, CommandType.StoredProcedure, reader =>
             new TestType
             {
                 TestTypeID = reader.Get<int>(0),
                 TestTypeCode = reader.Get<string>(1),
                 TestTypeName = reader.Get<string>(2),
                 DeterminationRequired = reader.Get<bool>(3),
             });
        }

        public async Task<DataSet> GetReserveCapacityLookUp(IEnumerable<string> cropCodes)
        {
            var data = await DbContext.ExecuteDataSetAsync(DataConstants.PR_PLAN_GET_RESERVECAPACITY_LOOKUP,
                CommandType.StoredProcedure, args => args.Add("@AccessibleCropCodes", string.Join(",", cropCodes)));
            data.Tables[0].TableName = "BreedingStation";
            data.Tables[1].TableName = "Crop";
            data.Tables[2].TableName = "TestType";
            data.Tables[3].TableName = "MaterialState";
            data.Tables[4].TableName = "Period";
            return data;

        }

        public async Task<PlanPeriod> GetCurrentPlanPeriodAsync()
        {
            var items = await DbContext.ExecuteReaderAsync(DataConstants.PR_PLAN_GET_CURRENT_PERIOD,
                CommandType.StoredProcedure, args => args.Add("@DetailAlso", true), reader => new PlanPeriod
                {
                    PeriodID = reader.Get<int>(0),
                    PeriodName = reader.Get<string>(1),
                    StartDate = reader.Get<DateTime>(2),
                    EndDate = reader.Get<DateTime>(3),
                    Remark = reader.Get<string>(4)
                });
            return items.FirstOrDefault();
        }

        public Task<IEnumerable<PlanPeriod>> GetPlanPeriodsAsync(int? year)
        {
            return DbContext.ExecuteReaderAsync(DataConstants.PR_PLAN_GET_PLAN_PERIODS_LOOKUP,
                CommandType.StoredProcedure,
                args => args.Add("@Year", year),
                reader => new PlanPeriod
                {
                    PeriodID = reader.Get<int>(0),
                    PeriodName = reader.Get<string>(1),
                    StartDate = reader.Get<DateTime>(2),
                    EndDate = reader.Get<DateTime>(3),
                    Remark = reader.Get<string>(4)
                });
        }

        public async Task<GetDisplayPeriodResult> GetDisplayPeriodAsync(DateTime request)
        {
            var data = await DbContext.ExecuteReaderAsync(DataConstants.PR_PLAN_GET_PERIOD_DETAIL,
                CommandType.StoredProcedure,
                args =>
                {
                    args.Add("@InputDate", request);
                }, reader => new GetDisplayPeriodResult()
                {
                    DisplayPeriod = reader.Get<string>(0)
                });

            return data.FirstOrDefault();
        }
    }
}
