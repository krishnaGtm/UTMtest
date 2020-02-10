using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using Enza.UTM.DataAccess.Abstract;
using Enza.UTM.DataAccess.Data.Interfaces;
using Enza.UTM.DataAccess.Interfaces;
using Enza.UTM.Entities.Args;
using Enza.UTM.Entities.Results;
using Enza.UTM.Common.Extensions;
using System.Linq;
using System.Configuration;

namespace Enza.UTM.DataAccess.Data.Repositories
{
    public class MaterialRepository : Repository<object>, IMaterialRepository
    {
        private readonly IUserContext userContext;
        public MaterialRepository(IDatabase dbContext, IUserContext userContext) : base(dbContext)
        {
            this.userContext = userContext;
        }

        public async Task<bool> DeleteDeadMaterialAsync(DeleteMaterialRequestArgs requestArgs)
        {
            await DbContext.ExecuteNonQueryAsync(DataConstants.PR_DELETE_DEAD_MATERIAL, CommandType.StoredProcedure, args =>
            {
                args.Add("@TestID", requestArgs.TestID);
            });
            return true;
        }
        public async Task<bool> ReplicateMaterial(ReplicateMaterialRequestArgs requestArgs)
        {
            await DbContext.ExecuteNonQueryAsync(DataConstants.PR_REPLICATE_MATERIAL, CommandType.StoredProcedure, args =>
            {
                args.Add("@TestID", requestArgs.TestID);
                //args.Add("@UserID", userContext.GetContext().FullName);
                args.Add("@NrOfReplicate", requestArgs.NoOfReplicate);
                args.Add("@Collated", requestArgs.Collated);
                args.Add("@TVP_Material", requestArgs.ToReplicateMaterial());
                args.Add("@MaxPlates", ConfigurationManager.AppSettings["App:MaxNoOfPlates"].ToInt64());
            });
            return true;
        }

        public async Task<DeleteMaterialResult> MarkDeadAsync(DeleteMaterialRequestArgs requestArgs)
        {
            var data = await DbContext.ExecuteReaderAsync(DataConstants.PR_MATERIAL_MARKASDEAD, CommandType.StoredProcedure, args =>
            {
                args.Add("@TestID", requestArgs.TestID);
                args.Add("@WellIDs", string.Join(",",requestArgs.WellIDs));
            },
            reader => new DeleteMaterialResult
            {
                WellTypeID = reader.Get<int>(0),
                TestID = reader.Get<int>(1),
                StatusCode = reader.Get<int>(2),
            });
            return data.FirstOrDefault();
        }

        public async Task<IEnumerable<MaterialLookupResult>> GetLookupAsync(MaterialLookupRequestArgs requestArgs)
        {
            return await DbContext.ExecuteReaderAsync(DataConstants.PR_GET_PLANTS_LOOKUP, CommandType.StoredProcedure, args =>
            {
                args.Add("@TestID", requestArgs.TestID);
                //args.Add("@UserID", userContext.GetContext().FullName);
                args.Add("@Query", requestArgs.Query);
            }, reader => new MaterialLookupResult
            {
                MaterialID = reader.Get<int>(0),
                MaterialKey = reader.Get<string>(1)
            });
        }

        public async Task<IEnumerable<MaterialStateResult>> GetMaterialStateAsync()
        {
            return await DbContext.ExecuteReaderAsync(DataConstants.PR_GET_MATERIALSTATE, CommandType.StoredProcedure,
                    reader => new MaterialStateResult
                    {
                        MaterialStateID = reader.Get<int>(0),
                        MaterialStateCode = reader.Get<string>(1),
                        MaterialStateDescription = reader.Get<string>(2)
                    });
        }

        public async Task<IEnumerable<MaterialTypeResult>> GetMaterialTypeAsync()
        {
            return await DbContext.ExecuteReaderAsync(DataConstants.PR_GET_MATERIALTYPE, 
                CommandType.StoredProcedure,
                    reader => new MaterialTypeResult
                    {
                        MaterialTypeID = reader.Get<int>(0),
                        MaterialTypeCode = reader.Get<string>(1),
                        MaterialTypeDescription = reader.Get<string>(2)
                    });
        }

        public async Task<bool> DeleteReplicateMaterialAsync(DeleteReplicateMaterialRequestArgs requestArgs)
        {
            await DbContext.ExecuteNonQueryAsync(DataConstants.PR_DELETE_REPLICATED_MATERIAL, CommandType.StoredProcedure, args =>
            {
                args.Add("@TestID", requestArgs.TestID);
                args.Add("@MaterialID", requestArgs.MaterialID);
                args.Add("@WellID", requestArgs.WellID);
            });
            return true;
        }

        public async Task<DeleteMaterialResult> UndoDeadAsync(DeleteMaterialRequestArgs requestArgs)
        {
            var data = await DbContext.ExecuteReaderAsync(DataConstants.PR_UNDO_DEAD, CommandType.StoredProcedure, args =>
            {
                args.Add("@TestID", requestArgs.TestID);
                args.Add("@WellIDs", string.Join(",", requestArgs.WellIDs));
            },
            reader => new DeleteMaterialResult
            {
                WellTypeID = reader.Get<int>(0),
                TestID = reader.Get<int>(1),
                StatusCode = reader.Get<int>(2),
            });
            return data.FirstOrDefault();
        }

        public async Task<bool> AddMaterialAsync(AddMaterialRequestArgs requestArgs)
        {
            await DbContext.ExecuteNonQueryAsync(DataConstants.PR_ADD_MATERIAL, CommandType.StoredProcedure, args =>
            {
                args.Add("@TestID", requestArgs.TestID);
                args.Add("@Filter", requestArgs.ToFilterString());
                args.Add("@Columns", requestArgs.ToColumnsString());
                args.Add("@TVP_3GBMaterial", requestArgs.ToTVP());
            });
            return true;
        }

        public async Task<DataWithMarkerResult> GetSelectedDataAsync (AddMaterialRequestArgs requestArgs)
        {
            var result = new DataWithMarkerResult();
            var data =  await DbContext.ExecuteDataSetAsync(DataConstants.PR_GET_SELECTED_DATA, CommandType.StoredProcedure, args =>
            {
                args.Add("@TestID", requestArgs.TestID);                
                args.Add("@Page", requestArgs.PageNumber);
                args.Add("@PageSize", requestArgs.PageSize);
                args.Add("@FilterQuery", requestArgs.ToFilterString());
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
