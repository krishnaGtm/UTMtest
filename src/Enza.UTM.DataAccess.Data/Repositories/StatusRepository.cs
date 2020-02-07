using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using Enza.UTM.DataAccess.Abstract;
using Enza.UTM.DataAccess.Data.Interfaces;
using Enza.UTM.DataAccess.Interfaces;
using Enza.UTM.Entities;
using Enza.UTM.Entities.Args;

namespace Enza.UTM.DataAccess.Data.Repositories
{
    public class StatusRepository : Repository<StatusLookup>, IStatusRepository
    {
        public StatusRepository(IDatabase dbContext) : base(dbContext)
        {
        }

        public async Task<IEnumerable<StatusLookup>> GetLookupAsync(string statusTable)
        {
            return await DbContext.ExecuteReaderAsync(DataConstants.PR_GETSTATUSLIST, CommandType.StoredProcedure, args =>
            {
                args.Add("@StatusTable", statusTable);
            }, reader => new StatusLookup
            {
                StatusCode = reader.Get<int>(0),
                StatusName = reader.Get<string>(1)
            });
        }
    }
}
