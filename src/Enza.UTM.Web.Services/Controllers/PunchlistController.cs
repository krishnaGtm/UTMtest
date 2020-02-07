using System.Threading.Tasks;
using System.Web.Http;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.Web.Services.Core.Controllers;

namespace Enza.UTM.Web.Services.Controllers
{
    [RoutePrefix("api/v1/punchlist")]
    public class PunchlistController : BaseApiController
    {
        readonly IPunchlistService punchlistService;
        public PunchlistController(IPunchlistService punchlistService)
        {
            this.punchlistService = punchlistService;
        }

        [HttpGet]
        [Route("getPunchlist")]
        public async Task<IHttpActionResult> Get(int testID)
        {
            var testLookups = await punchlistService.GetPunchlistAsync(testID);
            return Ok(testLookups);
        }

    }
}
