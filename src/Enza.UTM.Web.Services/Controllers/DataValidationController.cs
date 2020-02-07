using System.Threading.Tasks;
using System.Web.Http;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.Web.Services.Core.Controllers;

namespace Enza.UTM.Web.Services.Controllers
{
    [RoutePrefix("api/v1/validateData")]
    public class DataValidationController : BaseApiController
    {
        readonly IDataValidationService service;

        public DataValidationController(IDataValidationService service)
        {
            this.service = service;
        }

        [HttpGet]
        [Route("ValidateTraitDeterminationResult")]
        public async Task<IHttpActionResult> ValidateMigrationData(string source)
        {
            var data = await service.ValidateTraitDeterminationResultAsync(null, false, source);
            return Ok(data);
        }
    }
        
}