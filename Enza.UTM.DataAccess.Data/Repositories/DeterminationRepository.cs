using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using Enza.UTM.Common.Extensions;
using Enza.UTM.DataAccess.Abstract;
using Enza.UTM.DataAccess.Data.Interfaces;
using Enza.UTM.DataAccess.Interfaces;
using Enza.UTM.Entities.Args;
using Enza.UTM.Entities.Results;
using Enza.UTM.Entities;
using System.Linq;

namespace Enza.UTM.DataAccess.Data.Repositories
{
    public class DeterminationRepository : Repository<object>, IDeterminationRepository
    {
        private readonly IUserContext userContext;
        public DeterminationRepository(IDatabase dbContext, IUserContext userContext) : base(dbContext)
        {
            this.userContext = userContext;
        }
        public async Task<IEnumerable<DeterminationResult>> GetDeterminationsAsync(DeterminationRequestArgs request)
        {
            return await DbContext.ExecuteReaderAsync(DataConstants.PR_GET_DETERMINATIONS, CommandType.StoredProcedure, args =>
            {
                //args.Add("@UserID", userContext.GetContext().FullName);
                args.Add("@CropCode", request.CropCode);
                args.Add("@TestTypeID", request.TestTypeID);
                args.Add("@TestID", request.TestID);
            }, reader => new DeterminationResult
            {
                DeterminationID = reader.Get<int>(0),
                DeterminationName = reader.Get<string>(1),
                DeterminationAlias = reader.Get<string>(2),
                ColumnLabel = reader.Get<string>(3)
            });
        }

        public async Task<Test> AssignDeterminationsAsync(AssignDeterminationRequestArgs request)
        {
            var data = await DbContext.ExecuteReaderAsync(DataConstants.PR_SAVE_TEST_MATERIAL_DETERMINATION, CommandType.StoredProcedure, args =>
            {
                //args.Add("@UserID", userContext.GetContext().FullName);
                args.Add("@TestTypeID", request.TestTypeID);
                args.Add("@TestID", request.TestID);
                args.Add("@Columns", request.ToColumnsString());
                args.Add("@Filter", request.ToFilterString());
                args.Add("@TVPM", request.ToTVPTestMaterialDetermation());
                args.Add("@Determinations", request.ToTVPDeterminations());
            },
            reader => new Test
            {
                TestID = reader.Get<int>(0),
                StatusCode = reader.Get<int>(1)

            });
            return data.FirstOrDefault();
            //return true;
        }
        public async Task<DataWithMarkerResult> GetDataWithDeterminationsAsync(DataWithMarkerRequestArgs request)
        {
            var result = new DataWithMarkerResult();
            DbContext.CommandTimeout = 120;
            var data = await DbContext.ExecuteDataSetAsync(DataConstants.PR_GET_DATA_WITH_MARKERS, CommandType.StoredProcedure, args =>
            {
                args.Add("@TestID", request.TestID);
                //args.Add("@User", userContext.GetContext().FullName);
                args.Add("@Page", request.PageNumber);
                args.Add("@PageSize", request.PageSize);
                args.Add("@Filter", request.ToFilterString());
            });
            if (data.Tables.Count == 2)
            {
                var table0 = data.Tables[0];
                if (table0.Columns.Contains("TotalRows"))
                {
                    if (table0.Rows.Count > 0)
                    {
                        result.Total = table0.Rows[0]["TotalRows"].ToInt32();
                    }
                    table0.Columns.Remove("TotalRows");
                }
                result.Data = new
                {
                    Columns = data.Tables[1],
                    Data = table0
                };                
            }
            return result;
        }

        public async Task<MaterialsWithMarkerResult> GetMaterialsWithDeterminationsAsync(MaterialsWithMarkerRequestArgs request)
        {
            var result = new MaterialsWithMarkerResult();
            DbContext.CommandTimeout = 2 * 60; //time out is set to 2 minutes
            var data = await DbContext.ExecuteDataSetAsync(DataConstants.PR_GET_MATERIAL_WITH_MARKER, CommandType.StoredProcedure, args =>
            {
                args.Add("@TestID", request.TestID);
                //args.Add("@UserID", userContext.GetContext().FullName);
                args.Add("@Page", request.PageNumber);
                args.Add("@PageSize", request.PageSize);
                args.Add("@Filter", request.ToFilterString());
            });
            if (data.Tables.Count == 2)
            {
                var table0 = data.Tables[0];
                if (table0.Columns.Contains("TotalRows"))
                {
                    if (table0.Rows.Count > 0)
                    {
                        result.Total = table0.Rows[0]["TotalRows"].ToInt32();
                    }
                    table0.Columns.Remove("TotalRows");
                }
                result.Data = new
                {
                    Columns = data.Tables[1],
                    Data = table0
                };
            }
            return result;
        }

        public Task<IEnumerable<DeterminationResult>> GetDeterminationsForExternalTestsAsync(ExternalDeterminationRequestArgs requestArgs)
        {
            return DbContext.ExecuteReaderAsync(DataConstants.PR_GET_DETERMINATIONS_FOR_EXTERNAL_TESTS, CommandType.StoredProcedure, args =>
            {
                args.Add("@CropCode", requestArgs.CropCode);
                args.Add("@TestTypeID", requestArgs.TestTypeID);
            }, reader => new DeterminationResult
            {
                DeterminationID = reader.Get<int>(0),
                DeterminationName = reader.Get<string>(1),
                DeterminationAlias = reader.Get<string>(2),
                ColumnLabel = reader.Get<string>(3)
            });
        }

        public async Task<MaterialsWithMarkerResult> GetMaterialsWithDeterminationsForExternalTestAsync(MaterialsWithMarkerRequestArgs request)
        {
            var result = new MaterialsWithMarkerResult();
            //DbContext.CommandTimeout = 2 * 60; //time out is set to 2 minutes
            var data = await DbContext.ExecuteDataSetAsync(DataConstants.PR_GET_MATERIAL_WITH_MARKER_FOR_EXTERNAL_TEST, CommandType.StoredProcedure, args =>
            {
                args.Add("@TestID", request.TestID);
                //args.Add("@UserID", userContext.GetContext().FullName);
                args.Add("@Page", request.PageNumber);
                args.Add("@PageSize", request.PageSize);
                args.Add("@Filter", request.ToFilterString());
            });
            if (data.Tables.Count == 2)
            {
                var table0 = data.Tables[0];
                if (table0.Columns.Contains("TotalRows"))
                {
                    if (table0.Rows.Count > 0)
                    {
                        result.Total = table0.Rows[0]["TotalRows"].ToInt32();
                    }
                    table0.Columns.Remove("TotalRows");
                }
                result.Data = new
                {
                    Columns = data.Tables[1],
                    Data = table0
                };
            }
            return result;
        }
    }
}
