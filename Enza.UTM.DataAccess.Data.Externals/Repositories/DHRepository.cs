using System.Collections.Generic;
using System.Threading.Tasks;
using Enza.UTM.DataAccess.Abstract;
using Enza.UTM.DataAccess.Interfaces;
using Enza.UTM.DataAccess.Data.Externals.Interfaces;
using Enza.UTM.Entities.Externals.Args;
using System.Data;
using Enza.UTM.Common.Extensions;

namespace Enza.UTM.DataAccess.Data.Externals.Repositories
{
    public class DHRepository : Repository<object>, IDHRepository
    {
        public DHRepository(IDatabase dbContext) : base(dbContext)
        {
        }

        public async Task StoreDH0Async(IEnumerable<StoreDH0RequestArgs> requestArgs)
        {
            var dataAsJson = requestArgs.ToJson();
            await DbContext.ExecuteNonQueryAsync(DataConstants.PR_S2S_STORE_DH0_DETAILS,
                CommandType.StoredProcedure,
                args => { args.Add("@DataAsJson", dataAsJson); });
        }
    }
}
