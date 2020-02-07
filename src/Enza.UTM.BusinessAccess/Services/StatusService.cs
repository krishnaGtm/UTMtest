using System.Collections.Generic;
using System.Threading.Tasks;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.DataAccess.Data.Interfaces;
using Enza.UTM.Entities;
using Enza.UTM.Entities.Args;

namespace Enza.UTM.BusinessAccess.Services
{
    public class StatusService : IStatusService
    {
        readonly IStatusRepository statusRepository;
        public StatusService(IStatusRepository statusRepository)
        {
            this.statusRepository = statusRepository;
        }
        public async Task<IEnumerable<StatusLookup>> GetLookupAsync(string statusTable)
        {
            return await statusRepository.GetLookupAsync(statusTable);
        }
    }
}
