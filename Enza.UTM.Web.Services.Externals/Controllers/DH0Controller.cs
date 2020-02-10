using System.Collections.Generic;
using System.Threading.Tasks;
using System.Web.Http;
using Enza.UTM.BusinessAccess.Externals.Interfaces;
using Enza.UTM.Entities.Externals;
using Enza.UTM.Entities.Externals.Args;
using Enza.UTM.Web.Services.Core.Controllers;

namespace Enza.UTM.Web.Services.Externals.Controllers
{
    [RoutePrefix("api/v1/DH0")]
    [Authorize(Roles = AppRoles.UTM_S2S_DH_PRODUCTION)]
    public class DH0Controller : BaseApiController
    {
        private readonly IDHService _dHService;

        public DH0Controller(IDHService dHService)
        {
            _dHService = dHService;
        }

        [HttpPost]
        [Route("StoreDH0")]
        public async Task<IHttpActionResult> StoreDH0([FromBody] IEnumerable<StoreDH0RequestArgs> args)
        {
            if (args == null)
                return InvalidRequest("Please provide required parameters.");

            await _dHService.StoreDH0Async(args);

            return Ok();
        }
    }
}
