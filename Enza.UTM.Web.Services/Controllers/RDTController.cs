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
    [RoutePrefix("api/v1/rdt")]
    [Authorize(Roles = AppRoles.PUBLIC)]
    public class RDTController : BaseApiController
    {
        private readonly IRDTService _rdtService;
        private readonly IPhenomeServices _phenomeServices;
        private readonly IFileService _fileService;

        public RDTController(IRDTService rdtService, IPhenomeServices phenomeServices, IFileService fileService)
        {
            this._rdtService = rdtService;
            _phenomeServices = phenomeServices;
            _fileService = fileService;
        }
       
        [HttpPost]
        [Route("import")]
        public async Task<IHttpActionResult> Import([FromBody]PhenomeImportRequestArgs args)
        {
            if (string.IsNullOrWhiteSpace(args.TestName))
                return InvalidRequest("Please provide test name.");
            if (string.IsNullOrWhiteSpace(args.CropID))
                return InvalidRequest("Please provide research group ID.");
            if (string.IsNullOrWhiteSpace(args.FolderID))
                return InvalidRequest("Please provide folder ID.");

            var data = await _phenomeServices.GetPhenomeDataAsync(Request, args);
            var fileInfo = await _fileService.GetFileAsync(args.TestID);
            var result = new
            {
                data.Success,
                data.Errors,
                data.Warnings,
                data.Total,
                data.DataResult,
                args.TestID,
                File = fileInfo
            };
            return Ok(result);
        }

        [Route("getData")]
        [HttpPost]
        public async Task<IHttpActionResult> GetData([FromBody] ExcelDataRequestArgs args)
        {
            var ds = await _rdtService.GetDataAsync(args);
            var rs = new
            {
                Data = ds,
                args.TotalRows
            };
            return Ok(rs);
        }

        [Route("getmaterialwithtests")]
        [HttpPost]
        public async Task<IHttpActionResult> Getmaterialwithtests([FromBody] MaterialsWithMarkerRequestArgs args)
        {
            var ds = await _rdtService.GetMaterialWithTestsAsync(args);
            var rs = new
            {
                Data = ds,
                args.TotalRows
            };
            return Ok(rs);
        }

    }
}