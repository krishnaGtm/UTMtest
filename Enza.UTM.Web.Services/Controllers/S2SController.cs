using System.Configuration;
using System.Threading.Tasks;
using System.Web.Http;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.Common.Extensions;
using Enza.UTM.Entities;
using Enza.UTM.Entities.Args;
using Enza.UTM.Web.Services.Core.Controllers;

namespace Enza.UTM.Web.Services.Controllers
{
    [RoutePrefix("api/v1/s2s")]
    [Authorize(Roles = AppRoles.PUBLIC)]
    public class S2SController : BaseApiController
    {
        private readonly IS2SService _s2SService;
        private readonly IPhenomeServices _phenomeServices;
        private readonly IFileService _fileService;

        public S2SController(IS2SService s2SService, IPhenomeServices phenomeServices, IFileService fileService)
        {
            this._s2SService = s2SService;
            _phenomeServices = phenomeServices;
            _fileService = fileService;
        }

        [Route("getData")]
        [HttpPost]
        public async Task<IHttpActionResult> GetData([FromBody]ExcelDataRequestArgs args)
        {
            var ds = await _s2SService.GetDataAsync(args);
            var rs = new
            {
                Data = ds,
                args.TotalRows
            };
            return Ok(rs);
        }

        [HttpGet]
        [Route("getS2SCapacity")]
        public async Task<IHttpActionResult> GetS2SCapacity([FromUri] S2SCapacitySlotArgs args)
        {
            if (args.ImportLevel.EqualsIgnoreCase("list"))
                args.Source = "Seeds";
            else
                args.Source = "Plants";
            var resp = await _s2SService.GetS2SCapacityAsync(args);
            return Ok(resp);
        }
        [HttpPost]
        [Route("import")]
        public async Task<IHttpActionResult> Import([FromBody]S2SRequestArgs args)
        {
            if (string.IsNullOrWhiteSpace(args.TestName))
                return InvalidRequest("Please provide test name.");
            if (string.IsNullOrWhiteSpace(args.CropID))
                return InvalidRequest("Please provide research group ID.");
            if (string.IsNullOrWhiteSpace(args.FolderID))
                return InvalidRequest("Please provide folder ID.");

            var data = await _s2SService.ImportDataAsync(Request, args);
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
        [Route("assignDeterminationsForS2S")]
        public async Task<IHttpActionResult> AssignDeterminations([FromBody]AssignDeterminationForS2SRequestArgs args)
        {

            if (args == null)
                return InvalidRequest("Invlid paremeter.");
            var success = await _s2SService.AssignDeterminationsAsync(args);
            return Ok(success);
        }

        [HttpGet]
        [Route("MarkerWithMaterialS2S")]
        public async Task<IHttpActionResult> MarkerWithMaterialS2S([FromUri] MaterialsWithMarkerRequestArgs args)
        {
            if (args == null)
                return InvalidRequest("Invlid paremeter.");
            var resp = await _s2SService.MarkerWithMaterialS2SAsync(args);
            return Ok(resp);
        }

        [Route("getFillRate")]
        [HttpGet]
        public async Task<IHttpActionResult> GetFillRatesDetails(int testID)
        {

            if (testID <=0)
                return InvalidRequest("Invlid paremeter.");
            var ds = await _s2SService.GetFillRateDetailsAsync(testID);
            return Ok(ds);
        }

        [HttpPost]
        [Route("UploadS2SDonor")]
        public async Task<IHttpActionResult> UploadS2SDonor([FromBody]SendToS2SRequestArgs args)
        {
            if (args == null)
                return InvalidRequest("Invalid request args.");

            await _s2SService.UploadS2SDonorAsync(args.TestID);
            return Ok();
        }

        [HttpGet]
        [Route("getProjects")]
        public async Task<IHttpActionResult> GetProjects([FromUri] S2SCapacitySlotArgs args)
        {
            var ds = await _s2SService.GetProjectsAsync(args.Crop);
            return Ok(ds);
        }


        [HttpPost]
        [Route("manageMarkers")]
        public async Task<IHttpActionResult> ManageMarkers([FromBody]S2SManageMarkersRequestArgs args)
        {
            if (args == null)
                return InvalidRequest("Invlid paremeter.");

            await _s2SService.ManageMarkersAsync(args);

            return Ok();
        }
    }
}