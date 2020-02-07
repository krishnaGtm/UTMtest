using System.Threading.Tasks;
using System.Web.Http;
using Enza.UTM.BusinessAccess.Externals.Interfaces;
using Enza.UTM.Entities.Externals;
using Enza.UTM.Entities.Externals.Args;
using Enza.UTM.Web.Services.Core.Controllers;

namespace Enza.UTM.Web.Services.Externals.Controllers
{
    [RoutePrefix("api/v1/MarkerTestData")]
    [Authorize(Roles = AppRoles.UTM_S2S_DH_PRODUCTION)]
    public class MarkerTestDataController : BaseApiController
    {
        readonly IMarkerTestDataService _markerTestDataService;

        public MarkerTestDataController(IMarkerTestDataService markerTestDataService)
        {
            _markerTestDataService = markerTestDataService;
        }

        [HttpGet]
        [Route("getMarkerTestData")]
        public async Task<IHttpActionResult> GetMarkerTestData([FromUri] GetMarkerTestDataRequestArgs args)
        {
            if (args == null)
                return InvalidRequest("Please provide required parameters.");

            var data = await _markerTestDataService.GetMasterTestDataAsync(args);
            return Ok(data);
        }
    }
}
