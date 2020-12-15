using System.Configuration;
using System.Threading.Tasks;
using System.Web.Http;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.Entities;
using Enza.UTM.Entities.Args;
using Enza.UTM.Web.Services.Core.Controllers;

namespace Enza.UTM.Web.Services.Controllers
{
    [RoutePrefix("api/v1/threeGB")]
    [Authorize(Roles = AppRoles.PUBLIC)]
    public class ThreeGBController : BaseApiController
    {
        private readonly IThreeGBService _threeGBService;
        private readonly IPhenomeServices _phenomeServices;
        private readonly IFileService _fileService;

        public ThreeGBController(IThreeGBService threeGBService, IPhenomeServices phenomeServices, IFileService fileService)
        {
            _threeGBService = threeGBService;
            _phenomeServices = phenomeServices;
            _fileService = fileService;
        }

        [HttpGet]
        [Route("getAvailableProjects")]
        public async Task<IHttpActionResult> GetAvailableProjects([FromUri] AvailableThreeGBProjectsRequestArgs args)
        {
            if (args == null)
                return InvalidRequest("Please provide required parameters.");
            if (string.IsNullOrWhiteSpace(args.CropCode))
                return InvalidRequest("Please provide Crop Code.");
            if (string.IsNullOrWhiteSpace(args.BrStationCode))
                return InvalidRequest("Please provide Breeding Station code.");
            if (string.IsNullOrWhiteSpace(args.TestTypeCode))
                return InvalidRequest("Please provide Test Type Code.");

            var projects = await _threeGBService.GetAvailableProjectsAsync(args);
            return Ok(projects);
        }


        [HttpPost]
        [Route("import")]
        public async Task<IHttpActionResult> Import([FromBody]ThreeGBImportRequestArgs args)
        {
            if (string.IsNullOrWhiteSpace(args.TestName))
                return InvalidRequest("Please provide test name.");
            if (string.IsNullOrWhiteSpace(args.CropID))
                return InvalidRequest("Please provide research group ID.");
            if (string.IsNullOrWhiteSpace(args.FolderID))
                return InvalidRequest("Please provide folder ID.");

            var data = await _threeGBService.ImportDataAsync(Request, args);
            var fileInfo = await _fileService.GetFileAsync(args.TestID);
            var result = new
            {
                data.Success,
                data.Errors,
                data.Warnings,
                data.Total,
                data.DataResult,
                args.TestID,
                data.TotalCount,
                File = fileInfo
            };
            return Ok(result);
        }

        [HttpPost]
        [Route("sendTo3GBCockpit")]
        public async Task<IHttpActionResult> SendTo3GBCockpit([FromBody]SendTo3GBCockpitRequestArgs requestArgs)
        {
            if (requestArgs.TestID <= 0)
                return InvalidRequest("Please provide project name to send.");

            await _threeGBService.Upload3GBMaterialsAsync(requestArgs.TestID);

            return Ok(true);
        }
    }
}