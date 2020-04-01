using System;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using Enza.UTM.DataAccess.Abstract;
using Enza.UTM.DataAccess.Data.Planning.Interfaces;
using Enza.UTM.DataAccess.Interfaces;
using Enza.UTM.Entities.Args;
using Enza.UTM.Entities.Results;
using Enza.UTM.Common.Extensions;
using Enza.UTM.Entities;
using Enza.UTM.Common;
using System.Net.Mail;
using System.Net;

namespace Enza.UTM.DataAccess.Data.Planning.Repositories
{
    public class SlotRepository : Repository<object>, ISlotRepository
    {
        private readonly IUserContext userContext;
        public SlotRepository(IDatabase dbContext, IUserContext userContext) : base(dbContext)
        {
            this.userContext = userContext;
        }

        public async Task<GetAvailPlatesTestsResult> GetAvailPlatesTestsAsync(GetAvailPlatesTestsRequestArgs request)
        {
            var p1 = DbContext.CreateOutputParameter("@DisplayPlannedWeek", DbType.String, 100);
            var p2 = DbContext.CreateOutputParameter("@ExpectedDate", DbType.DateTime);
            var p3 = DbContext.CreateOutputParameter("@DisplayExpectedWeek", DbType.String, 100);
            var p4 = DbContext.CreateOutputParameter("@AvailPlates", DbType.Int32);
            var p5 = DbContext.CreateOutputParameter("@AvailTests", DbType.Int32);

            await DbContext.ExecuteReaderAsync(DataConstants.PR_PLAN_PLAN_GET_AVAIL_PLATES_TESTS,
                CommandType.StoredProcedure,
                args =>
                {
                    args.Add("@MaterialTypeID", request.MaterialTypeID);
                    args.Add("@CropCode", request.CropCode);
                    args.Add("@Isolated", request.Isolated);
                    args.Add("@PlannedDate", request.PlannedDate.ToDateTime());
                    args.Add("@DisplayPlannedWeek", p1);
                    args.Add("@ExpectedDate", p2);
                    args.Add("@DisplayExpectedWeek", p3);
                    args.Add("@AvailPlates", p4);
                    args.Add("@AvailTests", p5);
                });

            var data = new GetAvailPlatesTestsResult()
            {
                DisplayPlannedWeek = p1.Value.ToString(),
                ExpectedDate = p2.Value.ToDateTime(),
                DisplayExpectedWeek = p3.Value.ToString()
            };
            
            if (int.TryParse(p4.Value.ToString(), out var availPlates))
                data.AvailPlates = availPlates;
            if (int.TryParse(p5.Value.ToString(), out var availTests))
                data.AvailTests = availTests;

            return data;

        }

        public async Task<SlotLookUp> GetSlotDataAsync(int id)
        {
            var data = await DbContext.ExecuteReaderAsync(DataConstants.PR_PLAN_GET_SLOT_DATA, CommandType.StoredProcedure,
                args =>
                {
                    args.Add("@SlotID", id);
                }, reader => new SlotLookUp()
                {
                    SlotID = reader.Get<int>(0),
                    SlotName = reader.Get<string>(1),
                    BreedingStationCode = reader.Get<string>(2),
                    CropCode = reader.Get<string>(3),
                    RequestUser = reader.Get<string>(4),
                    TestType = reader.Get<string>(5),
                    MaterialType = reader.Get<string>(6),
                    MaterialState = reader.Get<string>(7),
                    Isolated = reader.Get<bool>(8),
                    TestProtocolName = reader.Get<string>(9),
                    NrOfPlates = reader.Get<int>(10),
                    NrOfTests = reader.Get<int>(11),
                    PlannedDate = reader.Get<DateTime>(12),
                    ExpectedDate = reader.Get<DateTime>(13)
                });

            return data.FirstOrDefault();
        }

        public async Task<EmailDataArgs> UpdateSlotPeriodAsync(UpdateSlotPeriodRequestArgs request)
        {
            var data = await DbContext.ExecuteReaderAsync(DataConstants.PR_PLAN_CHANGE_SLOT, CommandType.StoredProcedure,
               args =>
               {
                   args.Add("@SlotID", request.SlotID);
                   args.Add("@PlannedDate", request.PlannedDate);
                   args.Add("@ExpectedDate", request.ExpectedDate);
               }, reader => new EmailDataArgs
               {
                   ReservationNumber = reader.Get<string>(0),
                   SlotName = reader.Get<string>(1),
                   PeriodName = reader.Get<string>(2),
                   ChangedPeriodName = reader.Get<string>(3),
                   PlannedDate = reader.Get<DateTime>(4),
                   ChangedPlannedDate = reader.Get<DateTime>(5),
                   RequestUser = reader.Get<string>(6),
                   ExpectedDate = reader.Get<DateTime>(7),
                   ChangedExpectedDate = reader.Get<DateTime>(8),
                   ExpectedPeriodName = reader.Get<string>(9),
                   ChangedExpectedPeriodName = reader.Get<string>(10),
                   Action = "Changed"             
               });
            return data.FirstOrDefault();
            //send email
            //return await SendMail(data.FirstOrDefault());
        }

        
        public async Task<EmailDataArgs> ApproveSlotAsync(int SlotID)
        {
            //logic to approve request here
            var data = await DbContext.ExecuteReaderAsync(DataConstants.PR_PLAN_APPROVE_SLOT, CommandType.StoredProcedure,
               args =>
               {
                   args.Add("@SlotID", SlotID);
               }, reader => new EmailDataArgs
               {
                   ReservationNumber = reader.Get<string>(0),
                   SlotName = reader.Get<string>(1),
                   PeriodName = reader.Get<string>(2),
                   ChangedPeriodName = reader.Get<string>(3),
                   PlannedDate = reader.Get<DateTime>(4),
                   ChangedPlannedDate = reader.Get<DateTime>(5),
                   RequestUser = reader.Get<string>(6),
                   Action = "Approved"

               });
            return data.FirstOrDefault();
            //send email
            //return await SendMail(data.FirstOrDefault());
        }
        public async Task<EmailDataArgs> DenySlotAsync(int SlotID)
        {
            //logic to approve request here
            var data = await DbContext.ExecuteReaderAsync(DataConstants.PR_PLAN_REJECT_SLOT, CommandType.StoredProcedure,
               args =>
               {
                   args.Add("@SlotID", SlotID);
               }, reader => new EmailDataArgs
               {
                   ReservationNumber = reader.Get<string>(0),
                   SlotName = reader.Get<string>(1),
                   PeriodName = reader.Get<string>(2),
                   ChangedPeriodName = reader.Get<string>(3),
                   PlannedDate = reader.Get<DateTime>(4),
                   ChangedPlannedDate = reader.Get<DateTime>(5),
                   RequestUser = reader.Get<string>(6),
                   Action = "Rejected"

               });
            return data.FirstOrDefault();
            //send email
            //return await SendMail(data.FirstOrDefault());
        }

        public async Task<DataTable> GetPlannedOverviewAsync(int year, int? periodID)
        {
            var ds = await DbContext.ExecuteDataSetAsync(DataConstants.PR_PLAN_GET_PLANNED_OVERVIEW,
                CommandType.StoredProcedure,
                args =>
                {
                    args.Add("@Year", year);
                    args.Add("@PeriodID", periodID);
                });
            return ds.Tables[0];
        }

        

        public async Task<BreedingOverviewResult> GetBreedingOverviewAsync(BreedingOverviewRequestArgs requestArgs)
        {
            var ds = await DbContext.ExecuteDataSetAsync(DataConstants.PR_PLAN_GET_SLOTS_FOR_BREEDER,
                CommandType.StoredProcedure,
                args =>
                {
                    args.Add("@CropCode", requestArgs.CropCode);
                    args.Add("@BrStationCode", requestArgs.BrStationCode);
                    args.Add("@RequestUser", userContext.FullName);
                    args.Add("@Page", requestArgs.PageNumber);
                    args.Add("@PageSize", requestArgs.PageSize);
                    args.Add("@Filter", requestArgs.ToFilterString());
                });

            var result = new BreedingOverviewResult();
            if (ds.Tables.Count > 0)
            {
                var table0 = ds.Tables[0];
                if (table0.Columns.Contains("TotalRows"))
                {
                    if (table0.Rows.Count > 0)
                    {
                        result.Total = table0.Rows[0]["TotalRows"].ToInt32();
                    }
                    table0.Columns.Remove("TotalRows");
                }
                result.Data = table0;
            }
            return result;
        }

        public async Task<EditSlotResult> EditSlotAsync(EditSlotRequestArgs args)
        {
            var p1 = DbContext.CreateOutputParameter("@Message", DbType.String, 2000);
            var data = await DbContext.ExecuteDataSetAsync(DataConstants.PR_PLAN_EDIT_SLOT,
                CommandType.StoredProcedure, param =>
                {
                    param.Add("@SlotID", args.SlotID);
                    param.Add("@NrOfPlates", args.NrOfPlates);
                    param.Add("@NrOfTests", args.NrOfTests);
                    param.Add("@Forced", args.Forced);
                    param.Add("@Message", p1);
                });
            return new EditSlotResult
            {
                Success = string.IsNullOrWhiteSpace(p1.Value.ToText()) ? true : false,
                Message = p1.Value.ToText(),
                Data = data
            };
        }
        public async Task<DataTable> GetApprovedSlotsAsync(string userName, string slotName)
        {
            var ds = await DbContext.ExecuteDataSetAsync(DataConstants.PR_PLAN_GET_APPROVED_SLOTS,
                CommandType.StoredProcedure,
                args =>
                {
                    args.Add("@UserName", userName);
                    args.Add("@SlotName", slotName);
                });
            return ds.Tables[0];
        }
    }
}
