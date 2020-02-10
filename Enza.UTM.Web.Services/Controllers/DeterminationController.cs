using System.Threading.Tasks;
using System.Web.Http;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.Entities;
using Enza.UTM.Entities.Args;
using Enza.UTM.Web.Services.Core.Controllers;

namespace Enza.UTM.Web.Services.Controllers
{
    [RoutePrefix("api/v1/determination")]
    [Authorize(Roles = AppRoles.PUBLIC)]
    public class DeterminationController : BaseApiController
    {
        readonly IDeterminationService determinationService;
        public DeterminationController(IDeterminationService determinationService)
        {
            this.determinationService = determinationService;
        }

        public async Task<IHttpActionResult> Get([FromUri]DeterminationRequestArgs args)
        {
            var determminations = await determinationService.GetDeterminationsAsync(args);
            return Ok(determminations);
        }

        [HttpGet]
        [Route("getExternalDeterminations")]
        public async Task<IHttpActionResult> GetDeterminstaionsForExternalTests([FromUri]ExternalDeterminationRequestArgs requestArgs)
        {
            var determminations = await determinationService.GetDeterminationsForExternalTestsAsync(requestArgs);
            return Ok(determminations);
        }

        [HttpPost]
        [Route("assignDeterminations")]
        public async Task<IHttpActionResult> AssignDeterminations([FromBody]AssignDeterminationRequestArgs args)
        {
            var success = await determinationService.AssignDeterminationsAsync(args);
            return Ok(success);
        }

        [HttpPost]
        [Route("getDataWithDeterminations")]
        public async Task<IHttpActionResult> GetDataWithDeterminations([FromBody]DataWithMarkerRequestArgs args)
        {
            var determminations = await determinationService.GetDataWithDeterminationsAsync(args);
            return Ok(determminations);
        }

        [HttpPost]
        [Route("getMaterialsWithDeterminations")]
        public async Task<IHttpActionResult> GetMaterialsWithDeterminations([FromBody]MaterialsWithMarkerRequestArgs args)
        {
            var determminations = await determinationService.GetMaterialsWithDeterminationsAsync(args);
            return Ok(determminations);
        }

        [HttpPost]
        [Route("getMaterialsWithDeterminationsForExternalTest")]
        public async Task<IHttpActionResult> GetMaterialsWithDeterminationsForExternalTest([FromBody]MaterialsWithMarkerRequestArgs args)
        {
            var determminations = await determinationService.GetMaterialsWithDeterminationsForExternalTestAsync(args);
            return Ok(determminations);
        }
    }
}
