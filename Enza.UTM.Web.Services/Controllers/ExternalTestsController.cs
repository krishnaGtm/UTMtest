using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using System.Web.Http;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.Common.Extensions;
using Enza.UTM.Entities.Args;
using Enza.UTM.Web.Services.Core.Controllers;
using Enza.UTM.Web.Services.Models;

namespace Enza.UTM.Web.Services.Controllers
{
    [RoutePrefix("api/v1/externaltests")]
    public class ExternalTestsController : BaseApiController
    {
        private readonly IExternalTestService _externalTestService;
        private readonly IExcelDataService _excelDataService;
        private readonly IFileService _fileService;
        public ExternalTestsController(IExternalTestService externalTestService, IExcelDataService excelDataService, IFileService fileService)
        {
            _externalTestService = externalTestService;
            _fileService = fileService;
            _excelDataService = excelDataService;
        }

        [Route("getExternalTests")]
        [HttpGet]
        public async Task<IHttpActionResult> GetExternalTests(string cropCode, string brStationCode, bool showAll)
        {
            var data = await _externalTestService.GetExternalTestsLookupAsync(cropCode, brStationCode, showAll);
            return Ok(data);
        }

        [Route("import")]
        [HttpPost]
        [Authorize(Roles = "utm_importexternal")]
        public async Task<IHttpActionResult> ImportExcel()
        {
            if (!Request.Content.IsMimeMultipartContent())
                return InvalidRequest("Please upload file with enctype='multipart/form-data'.");

            var provider = await Request.Content.ReadAsMultipartAsync(new MultipartFormDataMemoryStreamProvider());
            //get file from content
            var file = provider.Contents.Where((content, idx) => provider.IsStream(idx)).FirstOrDefault();
            if (file == null)
                return InvalidRequest("File is either corrupted or invalid.");

            var fileName = file.Headers.ContentDisposition.FileName.Trim('\"');
            //this check should be done while creating file on DB because now file must be unique based on CropCode and breeding station code but not per user.
            //check if file is already exists for user
            //var fileExists = await fileService.FileExistsAsync(fileName);
            //if (fileExists)
            //{
            //    return InvalidRequest("File already exists.");
            //}

            var fs = await file.ReadAsStreamAsync();
            //save excel data to database
            var args = new ExternalTestImportRequestArgs
            {
                CropCode = provider.FormData["cropCode"],
                BrStationCode = provider.FormData["brStationCode"],
                TestTypeID = provider.FormData["testTypeID"].ToInt32(),
                PlannedDate = provider.FormData["plannedDate"].ToNDateTime(),
                MaterialStateID = provider.FormData["materialStateID"].ToInt32(),
                MaterialTypeID = provider.FormData["materialTypeID"].ToInt32(),
                ContainerTypeID = provider.FormData["containerTypeID"].ToInt32(),
                Isolated = provider.FormData["isolated"].ToBoolean(),
                Source = provider.FormData["source"],
                TestName = System.IO.Path.GetFileNameWithoutExtension(fileName),
                ExpectedDate = provider.FormData["expectedDate"].ToNDateTime(),
                PageSize = provider.FormData["pageSize"].ToInt32(),
                ExcludeControlPosition = provider.FormData["ExcludeControlPosition"].ToBoolean(),
                DataStream = fs
            };
            var result = await _externalTestService.ImportDataAsync(args);
            if (!result.Success)
            {
                return Ok(result);
            }
            //get imported data separately
            var data = await _excelDataService.GetDataAsync(new ExcelDataRequestArgs
            {
                TestID = args.TestID,
                TestTypeID = args.TestTypeID,
                PageNumber = 1,
                PageSize = args.PageSize
            });
            //get recently uploaded file details
            var fileInfo = await _fileService.GetFileAsync(args.TestID);
            var resp = new
            {
                result.Success,
                args.TestID,
                data.DataResult,
                data.Total,
                File = fileInfo
            };
            return Ok(resp);
        }

        [Route("export")]
        [HttpGet]
        [Authorize(Roles = "utm_importexternal")]
        public async Task<IHttpActionResult> ExportTest(int testID, bool mark = false)
        {
            var data = await _externalTestService.GetExcelFileForExternalTestAsync(testID, mark);

            var result = new HttpResponseMessage(HttpStatusCode.OK)
            {
                Content = new ByteArrayContent(data)
            };
            result.Content.Headers.ContentDisposition = new ContentDispositionHeaderValue("attachment")
            {
                FileName = $"External_Test_{testID}.xlsx"
            };
            result.Content.Headers.ContentType = new MediaTypeHeaderValue("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            return ResponseMessage(result);
        }
    }
}
