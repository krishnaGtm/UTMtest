using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using System.Web.Http;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.Entities;
using Enza.UTM.Entities.Args;
using Enza.UTM.Web.Services.Core.Controllers;

namespace Enza.UTM.Web.Services.Controllers
{
    [RoutePrefix("api/v1/cnt")]
    [Authorize(Roles = AppRoles.PUBLIC)]
    public class CNTController : BaseApiController
    {
        private readonly ICNTService _cNTService;
        private readonly IFileService _fileService;

        public CNTController(ICNTService cNTService, IFileService fileService)
        {
            _cNTService = cNTService;
            _fileService = fileService;
        }

        [HttpPost]
        [Route("import")]
        public async Task<IHttpActionResult> Import([FromBody]CNTRequestArgs args)
        {
            if (string.IsNullOrWhiteSpace(args.TestName))
                return InvalidRequest("Please provide test name.");
            if (string.IsNullOrWhiteSpace(args.CropID))
                return InvalidRequest("Please provide research group ID.");
            if (string.IsNullOrWhiteSpace(args.FolderID))
                return InvalidRequest("Please provide folder ID.");

            var data = await _cNTService.ImportDataAsync(Request, args);
            var success = !data.Errors.Any() && !data.Warnings.Any();
            var fileInfo = await _fileService.GetFileAsync(args.TestID);
            var result = new
            {
                Success = success,
                data.Errors,
                data.Warnings,               
                args.TestID,
                File = fileInfo,
                data.Total,
                data.DataResult
            };
            return Ok(result);
        }

        [HttpPost]
        [Route("assignMarkers")]
        public async Task<IHttpActionResult> AssignMarkers([FromBody]CNTAssignMarkersRequestArgs args)
        {
            if (args == null)
                return InvalidRequest("Invlid paremeter.");

            await _cNTService.AssignMarkersAsync(args);

            return Ok();
        }

        [HttpPost]
        [Route("manageInfo")]
        public async Task<IHttpActionResult> ManageInfo([FromBody]CNTManageInfoRequestArgs args)
        {
            if (args == null)
                return InvalidRequest("Invlid paremeter.");

            await _cNTService.ManageInfoAsync(args);

            return Ok();
        }

        [HttpPost]
        [Route("manageMarkers")]
        public async Task<IHttpActionResult> ManageMarkers([FromBody]CNTManageMarkersRequestArgs args)
        {
            if (args == null)
                return InvalidRequest("Invlid paremeter."); 

            await _cNTService.ManageMarkersAsync(args);

            return Ok();
        }

        [HttpGet]
        [Route("getDataWithMarkers")]
        public async Task<IHttpActionResult> GetDataWithMarkers([FromUri] MaterialsWithMarkerRequestArgs args)
        {
            if (args == null)
                return InvalidRequest("Please provide required parameters.");

            var resp = await _cNTService.GetDataWithMarkersAsync(args);
            return Ok(resp);
        }

        [HttpGet]
        [Route("exportToExcel")]
        public async Task<IHttpActionResult> ExportToExcel(int testID)
        {
            if (testID < 0)
                return InvalidRequest("Please provide required parameters.");

            var data = await _cNTService.GetDataForExcelAsync(testID);
            var result = new HttpResponseMessage(HttpStatusCode.OK)
            {
                Content = new ByteArrayContent(data)
            };
            result.Content.Headers.ContentDisposition = new ContentDispositionHeaderValue("attachment")
            {
                FileName = $"C&TMarkers{testID}.xlsx"
            };
            result.Content.Headers.ContentType = new MediaTypeHeaderValue("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            return ResponseMessage(result);
        }
    }
}