using Enza.UTM.DataAccess.Abstract;
using Enza.UTM.DataAccess.Interfaces;
using Enza.UTM.DataAccess.Data.Planning.Interfaces;
using System;
using System.Data;
using System.Threading.Tasks;
using Enza.UTM.Entities.Args;
using Enza.UTM.Entities.Results;
using System.Collections.Generic;
using Enza.UTM.Entities;

namespace Enza.UTM.DataAccess.Data.Planning.Repositories
{
    public class CapacityRepository : Repository<object>, ICapacityRepository
    {
        private readonly IUserContext userContext;
        public CapacityRepository(IDatabase dbContext, IUserContext userContext) : base(dbContext)
        {
            this.userContext = userContext;
        }

        public async Task<DataSet> GetCapacityAsync(int year)
        {
            var dataset =  await DbContext.ExecuteDataSetAsync(DataConstants.PR_PLAN_GET_CAPACITY, CommandType.StoredProcedure, args =>
            {                
                args.Add("@Year",year);
            });
            dataset.Tables[0].TableName = "Data";
            dataset.Tables[1].TableName = "Columns";
            return dataset;
            
        }

        public async Task<ReserveCapacityResult> ReserveCapacityAsync(ReserveCapacityRequestArgs args)
        {
            var p1 = DbContext.CreateOutputParameter("@IsSuccess", DbType.Boolean);
            var p2 = DbContext.CreateOutputParameter("@Message", DbType.String,2000);
            await DbContext.ExecuteNonQueryAsync(DataConstants.PR_PLAN_RESERVE_CAPACITY,
                CommandType.StoredProcedure, param =>
                {
                    param.Add("@BreedingStationCode", args.BreedingStationCode);
                    param.Add("@CropCode", args.CropCode);
                    param.Add("@TestTypeID", args.TestTypeID);
                    param.Add("@MaterialTypeID", args.MaterialTypeID);
                    param.Add("@MaterialStateID", args.MaterialStateID);
                    param.Add("@Isolated", args.Isolated);
                    param.Add("@PlannedDate", args.PlannedDate);
                    param.Add("@ExpectedDate", args.ExpectedDate);
                    param.Add("@NrOfPlates", args.NrOfPlates);
                    param.Add("@NrOfTests", args.NrOfTests);
                    param.Add("@User", userContext.GetContext().FullName);
                    param.Add("@Forced", args.Forced);
                    param.Add("@IsSuccess",p1);
                    param.Add("@Message",p2);
                });
            return new ReserveCapacityResult
            {
                Success = Convert.ToBoolean(p1.Value),
                Message = p2.Value.ToString()
            };
        
        }

        public async Task<DataSet> GetPlanApprovalListForLabAsync(int periodID)
        {
            var ds = await DbContext.ExecuteDataSetAsync(DataConstants.PR_PLAN_GET_PLAN_APPROVAL_LIST_FOR_LAB,
                CommandType.StoredProcedure,
                args => { args.Add("@periodID", periodID); }
            );
            ds.Tables[0].TableName = "Standard";
            ds.Tables[1].TableName = "Current";
            ds.Tables[2].TableName = "Columns";
            ds.Tables[3].TableName = "Details";
            return ds;
        }

        public async Task<bool> SaveCapacityAsync(SaveCapacityRequestArgs request)
        {
            await DbContext.ExecuteNonQueryAsync(DataConstants.PR_PLAN_SAVE_CAPACITY,
                CommandType.StoredProcedure, args =>
                {
                    args.Add("@TVP_Capacity", request.ToTVPCapacity());
                });

            return true;
        }

        public async Task<bool> MoveSlotAsync(MoveSlotRequestArgs args)
        {
            await DbContext.ExecuteNonQueryAsync(DataConstants.PR_PLAN_MOVE_CAPACITY_SLOT,
                CommandType.StoredProcedure, param =>
                {
                    param.Add("@SlotID", args.SlotID);
                    param.Add("@PlannedDate", args.PlannedDate);
                    param.Add("@ExpectedDate", args.ExpectedDate);
                });
            return true;
        }

        public async Task<bool> DeleteSlotAsync(int slotID)
        {
            await DbContext.ExecuteNonQueryAsync(DataConstants.PR_PLAN_REMOVE_SLOT,
                CommandType.StoredProcedure, param =>
                {
                    param.Add("@SlotID", slotID);
                    param.Add("@User", userContext.GetContext().FullName);

                });
            return true;

        }
    }
}
