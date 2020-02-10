using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using Enza.UTM.DataAccess.Abstract;
using Enza.UTM.DataAccess.Data.Interfaces;
using Enza.UTM.DataAccess.Interfaces;
using Enza.UTM.Entities;
using Enza.UTM.Entities.Args;
using Enza.UTM.Entities.Results;
using System.Configuration;
using Enza.UTM.Common.Extensions;

namespace Enza.UTM.DataAccess.Data.Repositories
{
    public class WellRepository : Repository<WellPosition>, IWellRepository
    {
        public WellRepository(IDatabase dbContext) : base(dbContext)
        {
        }

        public async Task<bool> AssignFixedPosition(AssignFixedPositionRequestArgs request)
        {
            var res = await DbContext.ExecuteNonQueryAsync(DataConstants.PR_ASSIGNFIXEDPLANTS, CommandType.StoredProcedure, args =>
            {
                args.Add("@Material", request.MaterialID);
                args.Add("@Position", request.WellPosition);
                args.Add("@TestID", request.TestID);
                args.Add("@MaxPlates", ConfigurationManager.AppSettings["App:MaxNoOfPlates"].ToInt64());               
            });
            return Convert.ToBoolean(res);
        }

        public async Task<bool> ReOrderMaterialPositionAsync(ReOrderMaterialPositionRequestArgs request)
        {
            await DbContext.ExecuteNonQueryAsync(DataConstants.PR_REORDER_MATERIAL,
                CommandType.StoredProcedure, args =>
                {
                    args.Add("@TestID", request.TestID);
                    args.Add("@TVP_Material_Well", request.ToTVPMaterialWell());
                });

            return true;
        }

        public async Task<IEnumerable<WellPosition>> GetLookupAsync(WellLookupRequestArgs request)
        {
            return await DbContext.ExecuteReaderAsync(DataConstants.PR_GET_WELLPOSITIONS_LOOKUP, CommandType.StoredProcedure, args =>
            {
                args.Add("@TestID", request.TestID);
            }, reader => new WellPosition
            {
                Position = reader.Get<string>(0)
            });
        }

        public async Task<IEnumerable<WellTypeResult>> GetWellTypeAsync()
        {
            return await DbContext.ExecuteReaderAsync(DataConstants.PR_GET_WELLTYPE, CommandType.StoredProcedure,
                reader => new WellTypeResult
                {
                    WellTypeID = reader.Get<int>(0),
                    BGColor = reader.Get<string>(1),
                    FGColor = reader.Get<string>(2),
                    WellTypeName = reader.Get<string>(3)
                });
        }

        public async Task<bool> UndoFixedPositionAsync(AssignFixedPositionRequestArgs request)
        {
            await DbContext.ExecuteNonQueryAsync(DataConstants.PR_UNDO_ASSIGN_FIXED_PLANTS, CommandType.StoredProcedure, args =>
            {
                args.Add("@TestID", request.TestID);
                args.Add("@MaterialID", request.MaterialID);
                args.Add("@Position", request.WellPosition);
            });
            return true;
        }
    }
}
