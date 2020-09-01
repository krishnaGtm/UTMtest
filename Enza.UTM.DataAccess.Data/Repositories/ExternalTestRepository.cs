using System.Data;
using System.Linq;
using System.Threading.Tasks;
using Enza.UTM.Common.Extensions;
using Enza.UTM.DataAccess.Abstract;
using Enza.UTM.DataAccess.Data.Interfaces;
using Enza.UTM.DataAccess.Interfaces;
using Enza.UTM.Entities;
using Enza.UTM.Entities.Args;
using Enza.UTM.Entities.Results;

namespace Enza.UTM.DataAccess.Data.Repositories
{
    public class ExternalTestRepository : Repository<object>, IExternalTestRepository
    {
        private readonly IUserContext userContext;

        public ExternalTestRepository(IDatabase dbContext, IUserContext userContext) : base(dbContext)
        {
            this.userContext = userContext;
        }

        public async Task<ExternalTestExportDataResult> GetExternalTestDataForExportAsync(int testID, bool markAsExported = false, bool traitScore = false)
        {
            var ds = await DbContext.ExecuteDataSetAsync(DataConstants.PR_GET_EXTERNAL_TEST_DATA_FOR_EXPORT,
                CommandType.StoredProcedure, args =>
                {
                    args.Add("@TestID", testID);
                    args.Add("@MarkAsExported", markAsExported);
                    args.Add("@TraitScore",traitScore);
                });

            return new ExternalTestExportDataResult
            {
                Data = ds.Tables[0],
                Columns = ds.Tables[1].AsEnumerable()
                .Select(o => new ExportColumnInfo
                {
                    ColumnID = o.Field<string>("ColumnID"),
                    ColumnLabel = o.Field<string>("ColumnLabel")
                }).ToList()
            };
        }

        public async Task<TestDetailExternal> GetExternalTestDetail(int testID)
        {
            var query = @"SELECT 
                            F.CropCode,
                            T.BreedingStationCode,
                            T.LabPlatePlanName,
                            T.StatusCode,
                            T.TestName,
                            T.RequestingSystem,
                        FROM Test T 
                        JOIN [File] F ON F.FileID = T.FileID
                        JOIN TestType TT ON TT.TestTypeID = T.TestTypeID
                        WHERE T.TestID = @TestID AND TT.TestTypeCode = @TestTypeCode";
            var result = await DbContext.ExecuteReaderAsync(query, CommandType.Text, args =>
              {
                  args.Add("@TestID", testID);
                  args.Add("@TestTypeCode", "MT");
              },
              reader=>new TestDetailExternal
              {
                  CropCode = reader.Get<string>(0),
                  BreedingStationCode = reader.Get<string>(1),
                  LabPlatePlanName = reader.Get<string>(2),
                  StatusCode = reader.Get<int>(3),
                  TestName = reader.Get<string>(4),
                  Source = reader.Get<string>(5)
              });
            return result.FirstOrDefault();
        }

        public async Task<DataTable> GetExternalTestsLookupAsync(string cropCode, string brStationCode, bool showAll)
        {
            var ds = await DbContext.ExecuteDataSetAsync(DataConstants.PR_GET_EXTERNAL_TESTS_LOOKUP,
                CommandType.StoredProcedure, args =>
                {
                    args.Add("@CropCode", cropCode);
                    args.Add("@BrStationCode", brStationCode);
                    args.Add("@ShowAll", showAll);
                });
            return ds.Tables[0];
        }

        public async Task ImportDataAsync(ExternalTestImportRequestArgs requestArgs, DataTable dtColumnsTVP, DataTable dtRowTVP, DataTable dtCellTVP)
        {
            var p1 = DbContext.CreateOutputParameter("@TestID", DbType.Int32);
            DbContext.CommandTimeout = 5 * 60; //5 minutes

            var dtListTVP = new DataTable("TVP_List");
            await DbContext.ExecuteNonQueryAsync(DataConstants.PR_IMPORT_EXTERNAL_DATA,
                CommandType.StoredProcedure, args =>
                {
                    args.Add("@TestID", p1);
                    args.Add("@CropCode", requestArgs.CropCode);
                    args.Add("@BreedingStationCode", requestArgs.BrStationCode);
                    args.Add("@SyncCode", "NL");
                    args.Add("@CountryCode", requestArgs.CountryCode);
                    args.Add("@TestTypeID", requestArgs.TestTypeID);
                    args.Add("@UserID", userContext.GetContext().FullName);
                    args.Add("@FileTitle", requestArgs.TestName);
                    args.Add("@TestName", requestArgs.TestName);                   
                    args.Add("@PlannedDate", requestArgs.PlannedDate);
                    args.Add("@MaterialStateID", requestArgs.MaterialStateID);
                    args.Add("@MaterialTypeID", requestArgs.MaterialTypeID);
                    args.Add("@ContainerTypeID", requestArgs.ContainerTypeID);
                    args.Add("@Isolated", requestArgs.Isolated);
                    args.Add("@ExpectedDate", requestArgs.ExpectedDate);
                    args.Add("@Source", requestArgs.Source);
                    args.Add("@ObjectID", null);
                    args.Add("@TVPColumns", dtColumnsTVP);
                    args.Add("@TVPRow", dtRowTVP);
                    args.Add("@TVPCell", dtCellTVP);
                    args.Add("@Cumulate", false);
                    args.Add("@ImportLevel", "PLT");
                    args.Add("@ExcludeControlPosition", requestArgs.ExcludeControlPosition);
                });
            requestArgs.TestID = p1.Value.ToInt32();
        }        
    }
}
