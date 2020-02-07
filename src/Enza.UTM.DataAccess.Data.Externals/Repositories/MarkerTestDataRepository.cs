using System.Data;
using System.Threading.Tasks;
using Enza.UTM.DataAccess.Abstract;
using Enza.UTM.DataAccess.Interfaces;
using Enza.UTM.DataAccess.Data.Externals.Interfaces;
using Enza.UTM.Entities.Externals.Args;

namespace Enza.UTM.DataAccess.Data.Externals.Repositories
{
    public class MarkerTestDataRepository : Repository<object>, IMarkerTestDataRepository
    {
        public MarkerTestDataRepository(IDatabase dbContext) : base(dbContext)
        {
        }
        public async Task<DataTable> GetMasterTestDataAsync(GetMarkerTestDataRequestArgs requestArgs)
        {
            var ds = await DbContext.ExecuteDataSetAsync(DataConstants.PR_S2S_GET_MARKER_TEST_DATA,
                CommandType.StoredProcedure,
                args =>
                {
                    args.Add("@TestID", requestArgs.TestID);
                    args.Add("@MaterialID", requestArgs.MaterialID);
                });
            return ds.Tables[0];
        }
    }
}
