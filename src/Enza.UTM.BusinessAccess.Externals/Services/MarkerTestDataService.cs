using System.Data;
using System.Threading.Tasks;
using Enza.UTM.BusinessAccess.Externals.Interfaces;
using Enza.UTM.DataAccess.Data.Externals.Interfaces;
using Enza.UTM.Entities.Externals.Args;

namespace Enza.UTM.BusinessAccess.Externals.Services
{
    public class MarkerTestDataService : IMarkerTestDataService
    {
        private readonly IMarkerTestDataRepository  _markerTestDataRepository;
        public MarkerTestDataService(IMarkerTestDataRepository markerTestDataRepository)
        {
            _markerTestDataRepository = markerTestDataRepository;
        }

        public Task<DataTable> GetMasterTestDataAsync(GetMarkerTestDataRequestArgs requestArgs)
        {
            return _markerTestDataRepository.GetMasterTestDataAsync(requestArgs);
        }
    }
}
