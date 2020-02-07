using System.Threading.Tasks;
using System.Web.Http;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.Entities;
using Enza.UTM.Entities.Args;
using Enza.UTM.Web.Services.Core.Controllers;

namespace Enza.UTM.Web.Services.Controllers
{
    [RoutePrefix("api/v1/emailConfig")]
    [Authorize(Roles = AppRoles.ADMIN)]
    public class EmailConfigController : BaseApiController
    {
        readonly IEmailConfigService  _emailConfigService;

        public EmailConfigController(IEmailConfigService emailConfigService)
        {
            _emailConfigService = emailConfigService;
        }

        [HttpGet]
        public async Task<IHttpActionResult> Get([FromUri]EmailConfigRequestArgs args)
        {
            var configs = await _emailConfigService.GetAllAsync(args);
            return Ok(new
            {
                Data = configs,
                Total = args.TotalRows
            });
        }

        [HttpPost]
        public async Task<IHttpActionResult> Post([FromBody]EmailConfig entity)
        {
            await _emailConfigService.AddAsync(entity);

            return Ok(true);
        }

        [HttpDelete]
        public async Task<IHttpActionResult> Delete([FromBody]DeleteEmailConfigRequestArgs entity)
        {
            await _emailConfigService.DeleteAsync(entity.ConfigID);
            return Ok(true);
        }
    }
}