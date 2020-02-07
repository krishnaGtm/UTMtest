using System.Threading.Tasks;
using System.Web.Http;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.Entities;
using Enza.UTM.Entities.Args;
using Enza.UTM.Web.Services.Core.Controllers;

namespace Enza.UTM.Web.Services.Controllers
{
    [Authorize(Roles = AppRoles.HANDLE_LAB_CAPACITY)]
    [RoutePrefix("api/v1/MaterialTypeTestProtocols")]
    public class MaterialTypeTestProtocolsController : BaseApiController
    {
        private readonly IMaterialTypeTestProtocolService _materialTypeTestProtocolService;
        public MaterialTypeTestProtocolsController(IMaterialTypeTestProtocolService materialTypeTestProtocolService)
        {
            _materialTypeTestProtocolService = materialTypeTestProtocolService;
        }

        [HttpPost]
        public async Task<IHttpActionResult> Post([FromBody]GetMaterialTypeTestProtocolsRequestArgs requestArgs)
        {
            var data = await _materialTypeTestProtocolService.GetDataAsync(requestArgs);
            return Ok(new
            {
                Data = data,
                Total = requestArgs.TotalRows
            });
        }

        [HttpPost]
        [Route("saveData")]
        public async Task<IHttpActionResult> SaveData([FromBody]SaveMaterialTypeTestProtocolsRequestArgs requestArgs)
        {
            await _materialTypeTestProtocolService.SaveDataAsync(requestArgs);

            return Ok(true);
        }
    }
}
