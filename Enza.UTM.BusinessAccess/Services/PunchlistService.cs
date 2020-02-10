using System.Collections.Generic;
using System.Threading.Tasks;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.DataAccess.Data.Interfaces;
using Enza.UTM.Entities.Results;

namespace Enza.UTM.BusinessAccess.Services
{
    public class PunchlistService : IPunchlistService
    {
        readonly IPunchlistRepository punchRepository;

        public PunchlistService(IPunchlistRepository punchRepository)
        {
            this.punchRepository = punchRepository;
        }
        public async Task<IEnumerable<Plate>> GetPunchlistAsync(int testID)
        {
            return await punchRepository.GetPunchlistAsync(testID);
        }
        
    }
}
