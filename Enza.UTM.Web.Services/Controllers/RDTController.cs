using System.Configuration;
using System.Linq;
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
    //[Authorize(Roles = AppRoles.PUBLIC)]
    public class RDTController : BaseApiController
    {
        private readonly IRDTService _rdtService;
        private readonly IPhenomeServices _phenomeServices;
        private readonly IFileService _fileService;
        private readonly ITestService _testService;

        public RDTController(IRDTService rdtService, IPhenomeServices phenomeServices, IFileService fileService, ITestService testService)
        {
            this._rdtService = rdtService;
            _phenomeServices = phenomeServices;
            _fileService = fileService;
            _testService = testService;
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

            //var data = await _phenomeServices.GetPhenomeDataAsync(Request, args);
            var data = await _rdtService.ImportDataFromPhenomeAsync(Request, args);

            var fileInfo = new ExcelFile();
            if(!(data.Errors.Any() || data.Warnings.Any()))
            {
                fileInfo = fileInfo = await _fileService.GetFileAsync(args.TestID);
            }
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
            var result = await _rdtService.GetDataAsync(args);
            return Ok(result);
        }

        [Route("getmaterialwithtests")]
        [HttpPost]
        public async Task<IHttpActionResult> Getmaterialwithtests([FromBody] MaterialsWithMarkerRequestArgs args)
        {
            var ds = await _rdtService.GetMaterialWithTestsAsync(args);            
            return Ok(ds);
        }


        [Route("assignTests")]
        [HttpPost]
        public async Task<IHttpActionResult> AssignTest([FromBody] AssignDeterminationForRDTRequestArgs args)
        {
            var ds = await _rdtService.AssignTestAsync(args);
            var rs = new
            {
                Data = ds,
                args.TotalRows
            };
            return Ok(rs);
        }

        [Route("requestSampleTest")]
        [HttpPost]
        public async Task<IHttpActionResult> RequestSampleTest([FromBody] TestRequestArgs args)
        {
            var rs = await _rdtService.RequestSampleTestAsync(args);

            await _testService.UpdateTestStatusAsync(new UpdateTestStatusRequestArgs
            {
                StatusCode = 200,
                TestId = args.TestID
            });

            return Ok(rs);
        }

        
        [Route("getmaterialstatus")]
        [HttpGet]
        public async Task<IHttpActionResult> getmaterialSatus()
        {
            
            var rs = await _rdtService.GetmaterialStatusAsync();
            return Ok(rs);
        }

        [OverrideAuthorization]
        [Authorize(Roles = AppRoles.HANDLE_LAB_CAPACITY + "," + AppRoles.REQUEST_TEST)]
        [HttpPost]
        [Route("getRDTtestOverview")]
        public async Task<IHttpActionResult> GetRDTtestsOverview([FromBody] PlatePlanRequestArgs args)
        {
            args.Crops = string.Join(",", User.GetClaims("enzauth.crops"));
            var rs = await _rdtService.GetRDTtestsOverviewAsync(args);
            return Ok(rs);
        }

        //[HttpPost]
        //[Route("RequestSampleTestCallBack")]
        ////[Authorize(Roles = AppRoles.HANDLE_LAB_CAPACITY + "," + AppRoles.REQUEST_TEST)]
        //public async Task<IHttpActionResult> RequestSampleTestCallBack([FromBody]RequestSampleTestCallBackRequestArgs requestArgs)
        //{
        //    if (requestArgs == null)
        //        return InvalidRequest("Please provide required parameters.");

        //    var result = await _rdtService.RequestSampleTestCallbackAsync(requestArgs);
        //    return Ok(result);
        //}

        //[HttpPost]
        //[Route("ReceiveRDTResults")]
        ////[Authorize(Roles = AppRoles.HANDLE_LAB_CAPACITY + "," + AppRoles.REQUEST_TEST)]
        //public async Task<IHttpActionResult> ReceiveRDTResults([FromBody]ReceiveRDTResultsRequestArgs requestArgs)
        //{
        //    if (requestArgs == null)
        //        return InvalidRequest("Please provide required parameters.");

        //    var result = await _rdtService.ReceiveRDTResultsAsync(requestArgs);
        //    return Ok(result);
        //}

        [Route("print")]
        [HttpPost]
        public async Task<IHttpActionResult> PrintLabel([FromBody]PrintLabelForRDTRequestArgs reqArgs)
        {
            if (reqArgs == null)
                return InvalidRequest("Please provide required parameters.");
           
            var history = await _rdtService.PrintLabelAsync(reqArgs);
            return Ok(history);
        }
    }
}