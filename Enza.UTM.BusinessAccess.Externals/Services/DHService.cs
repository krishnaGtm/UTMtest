using System.Collections.Generic;
using System.Threading.Tasks;
using Enza.UTM.BusinessAccess.Externals.Interfaces;
using Enza.UTM.DataAccess.Data.Externals.Interfaces;
using Enza.UTM.Entities.Externals.Args;

namespace Enza.UTM.BusinessAccess.Externals.Services
{
    public class DHService : IDHService
    {
        private readonly IDHRepository _dHRepository;
        public DHService(IDHRepository dHRepository)
        {
            _dHRepository = dHRepository;
        }
        public Task StoreDH0Async(IEnumerable<StoreDH0RequestArgs> args)
        {
            return _dHRepository.StoreDH0Async(args);
        }
    }
}
