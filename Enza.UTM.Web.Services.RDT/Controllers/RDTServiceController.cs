using System.Threading.Tasks;
using System.Web.Http;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.Entities.Args;
using Enza.UTM.Web.Services.Core.Controllers;

namespace Enza.UTM.Web.Services.RDT.Controllers
{
    [RoutePrefix("api/v1/rdt")]
    [Authorize]
    public class RDTServiceController : BaseApiController
    {
        private readonly IRDTService _rdtService;

        public RDTServiceController(IRDTService rdtService)
        {
            this._rdtService = rdtService;
        }

        [HttpPost]
        [Route("RequestSampleTestCallBack")]
        //[Authorize(Roles = AppRoles.HANDLE_LAB_CAPACITY + "," + AppRoles.REQUEST_TEST)]
        public async Task<IHttpActionResult> RequestSampleTestCallBack([FromBody]RequestSampleTestCallBackRequestArgs requestArgs)
        {
            if (requestArgs == null)
                return InvalidRequest("Please provide required parameters.");

            var result = await _rdtService.RequestSampleTestCallbackAsync(requestArgs);
            return Ok(result);
        }

        [HttpPost]
        [Route("ReceiveRDTResults")]
        //[Authorize(Roles = AppRoles.HANDLE_LAB_CAPACITY + "," + AppRoles.REQUEST_TEST)]
        public async Task<IHttpActionResult> ReceiveRDTResults([FromBody]ReceiveRDTResultsRequestArgs requestArgs)
        {
            if (requestArgs == null)
                return InvalidRequest("Please provide required parameters.");

            var result = await _rdtService.ReceiveRDTResultsAsync(requestArgs);
            return Ok(result);
        }

    }
}