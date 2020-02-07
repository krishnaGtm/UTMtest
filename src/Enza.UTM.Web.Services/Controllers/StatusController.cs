using System.Threading.Tasks;
using System.Web.Http;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.Entities;
using Enza.UTM.Web.Services.Core.Controllers;

namespace Enza.UTM.Web.Services.Controllers
{
    [RoutePrefix("api/v1/status")]
    [Authorize(Roles = AppRoles.PUBLIC)]
    public class StatusController : BaseApiController
    {
        readonly IStatusService statusService;

        public StatusController(IStatusService statusService)
        {
            this.statusService = statusService;
        }

        [HttpGet]
        [Route("getstatuslist/test")]
        public async Task<IHttpActionResult> GetTestStatusList()
        {
            var statusLookups = await statusService.GetLookupAsync("Test");
            return Ok(statusLookups);
        }
    }
}