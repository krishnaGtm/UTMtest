using System.Threading.Tasks;
using System.Web.Http;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.Entities;
using Enza.UTM.Entities.Args;
using Enza.UTM.Web.Services.Core.Controllers;

namespace Enza.UTM.Web.Services.Controllers
{
    [RoutePrefix("api/v1/materials")]
    [Authorize(Roles = AppRoles.PUBLIC)]
    public class MaterialsController : BaseApiController
    {
        readonly IMaterialService materialService;
        public MaterialsController(IMaterialService materialService)
        {
            this.materialService = materialService;
        }
        public async Task<IHttpActionResult> Get([FromUri]MaterialLookupRequestArgs requestArgs)
        {
            var materials = await materialService.GetLookupAsync(requestArgs);
            return Ok(materials);
        }
        [HttpDelete]
        //[Route("Delete")]
        [Route("markdead")]
        public async Task<IHttpActionResult> Markdead([FromBody]DeleteMaterialRequestArgs requestArgs)
        {
            var result = await materialService.MarkDeadAsync(requestArgs);
            return Ok(result);
        }

        [HttpDelete]
        [Route("UndoDead")]
        public async Task<IHttpActionResult> Undodead([FromBody]DeleteMaterialRequestArgs requestArgs)
        {
            var result = await materialService.UndoDeadAsync(requestArgs);
            return Ok(result);
           
        }

        [HttpGet]
        [Route("getMaterialstate")]
        public async Task<IHttpActionResult> GetMaterialState()
        {
            var result = await materialService.GetMaterialStateAsync();
            return Ok(result);
        }

        [HttpGet]
        [Route("getMaterialtype")]
        public async Task<IHttpActionResult> GetMaterialType()
        {
            var result = await materialService.GetMaterialTypeAsync();
            return Ok(result);
        }
        [HttpDelete]
        //[Route("DeleteMaterial")]
        [Route("DeleteDeadMaterial")]
        public async Task<IHttpActionResult> DeleteDeadMaterial([FromBody]DeleteMaterialRequestArgs requestArgs)
        {
            var result = await materialService.DeleteDeadMaterialAsync(requestArgs);
            return Ok(result);
        }

        [HttpPatch]
        [Route("replicate")]
        public async Task<IHttpActionResult> ReplicateMaterial([FromBody] ReplicateMaterialRequestArgs requestArgs)
        {
            var result = await materialService.ReplicateMaterial(requestArgs);
            return Ok(result);
        }

        [HttpDelete]
        [Route("DeleteReplicate")]
        public async Task<IHttpActionResult> DeleteReplicateMaterial([FromBody] DeleteReplicateMaterialRequestArgs requestArgs)
        {
            var result = await materialService.DeleteReplicateMaterialAsync(requestArgs);
            return Ok(result);
        }

        [HttpPost]
        [Route("AddMaterial")]
        public async Task<IHttpActionResult> AddMaterial([FromBody] AddMaterialRequestArgs requestArgs)
        {
            var result = await materialService.AddMaterialAsync(requestArgs);
            return Ok(result);
        }

        [HttpPost]
        [Route("getSelectedMaterial")]
        public async Task<IHttpActionResult> GetSelectedData([FromBody] AddMaterialRequestArgs requestArgs)
        {
            var result = await materialService.GetSelectedDataAsync(requestArgs);            
            return Ok(result);
        }
    }
}
