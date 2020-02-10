using System.Threading.Tasks;
using System.Web.Http;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.Entities;
using Enza.UTM.Entities.Args;
using Enza.UTM.Web.Services.Core.Controllers;

namespace Enza.UTM.Web.Services.Controllers
{
    [RoutePrefix("api/v1/well")]
    [Authorize(Roles = AppRoles.PUBLIC)]
    public class WellController : BaseApiController
    {
        readonly IWellService wellService;

        public WellController(IWellService wellService)
        {
            this.wellService = wellService;
        }

        [HttpGet]
        [Route("getwellpositions")]
        public async Task<IHttpActionResult> GetLookup([FromUri]WellLookupRequestArgs args)
        {
            var testLookups = await wellService.GetLookupAsync(args);
            return Ok(testLookups);
        }
        [HttpGet]
        [Route("getwelltypes")]
        public async Task<IHttpActionResult> GetWellType()
        {
            var testLookups = await wellService.GetWellTypeAsync();
            return Ok(testLookups);
        }

        [HttpPost]
        [Route("assignfixedposition")]
        public async Task<IHttpActionResult> AssignFixedPosition([FromBody]AssignFixedPositionRequestArgs args)
        {
            var result = await wellService.AssignFixedPositionAsync(args);
            return Ok(result);
        }
        [HttpPost]
        [Route("undofixedposition")]
        public async Task<IHttpActionResult> UndoFixedPosition([FromBody]AssignFixedPositionRequestArgs args)
        {
            var result = await wellService.UndoFixedPositionAsync(args);
            return Ok(result);
        }

        [HttpPost]
        [Route("save")]
        public async Task<IHttpActionResult> ReOrderMaterialPosition([FromBody] ReOrderMaterialPositionRequestArgs args)
        {
            var result = await wellService.ReOrderMaterialPositionAsync(args);
            return Ok(result);
        }
    }
}