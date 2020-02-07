using System.Threading.Tasks;
using System.Web.Http;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.Entities;
using Enza.UTM.Web.Services.Core.Controllers;

namespace Enza.UTM.Web.Services.Controllers
{
    [RoutePrefix("api/v1/testType")]
    [Authorize(Roles = AppRoles.PUBLIC)]
    public class TestTypeController : BaseApiController
    {
        readonly ITestTypeService testTypeService;
        public TestTypeController(ITestTypeService testTypeService)
        {
            this.testTypeService = testTypeService;
        }

        public async Task<IHttpActionResult> Get()
        {
            var testTypes = await testTypeService.GetLookupAsync();
            return Ok(testTypes);
        }
    }
}
