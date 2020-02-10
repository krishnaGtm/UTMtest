using System.Threading.Tasks;
using System.Web.Http;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.Entities;
using Enza.UTM.Web.Services.Core.Controllers;

namespace Enza.UTM.Web.Services.Controllers
{
    [RoutePrefix("api/v1/file")]
    [Authorize(Roles = AppRoles.PUBLIC)]
    public class FileController : BaseApiController
    {
        readonly IFileService fileService;
        public FileController(IFileService fileService)
        {
            this.fileService = fileService;
        }

        public async Task<IHttpActionResult> Get(string cropCode, string breedingStationCode)
        {
            var testTypes = await fileService.GetFilesAsync(cropCode, breedingStationCode);
            return Ok(testTypes);
        }
    }
}
