using System;
using System.Threading.Tasks;
using Enza.UTM.DataAccess.Abstract;
using Enza.UTM.DataAccess.Data.Interfaces;
using Enza.UTM.DataAccess.Interfaces;
using System.Data;
using Enza.UTM.Entities.Results;
using System.Collections.Generic;

namespace Enza.UTM.DataAccess.Data.Repositories
{
    public class DataValidationRepository : Repository<object>, IDataValidationRepository
    {
        public DataValidationRepository(IDatabase dbContext) : base(dbContext)
        {
        }
        public async Task<IEnumerable<MigrationDataResult>> ValidateTraitDeterminationResultAsync(int? testID, bool sendResult, string source)
        {

            DbContext.CommandTimeout = 600;
            return await DbContext.ExecuteReaderAsync(DataConstants.PR_UPDATE_AND_VERIFY_TRAIT_DETERMINATION_RESULT, CommandType.StoredProcedure, args =>
            {
                args.Add("@TestID", testID);
                args.Add("@Source", source);
                args.Add("@SendResult", sendResult);
            },
            reader => new MigrationDataResult
            {
                TestID = reader.Get<int>(0),
                TestName = reader.Get<string>(1),
                ListID = reader.Get<int?>(2),
                Materialkey = reader.Get<string>(3),
                ColumnLabel = reader.Get<string>(4),
                TraitValue = reader.Get<string>(5),
                DeterminationValue = reader.Get<string>(6),
                CropCode = reader.Get<string>(7),
                Cummulate = reader.Get<bool>(8),
                InvalidPer = reader.Get<decimal>(9),
                FieldID = reader.Get<string>(10),
                DeterminationName = reader.Get<string>(11),
                RequestingUser = reader.Get<string>(12),
                StatusCode = reader.Get<int>(13),
                IsValid = reader.Get<bool>(14),
                WellID = reader.Get<int>(15),
                Position = reader.Get<string>(16),
                PlateName = reader.Get<string>(17)
            });

        }
    }
}
