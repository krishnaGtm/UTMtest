using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;
using System.Web.Http;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.Common.Extensions;
using Enza.UTM.Entities.Args;
using Enza.UTM.Web.Services.Models;
using Enza.UTM.Web.Services.Core.Controllers;

namespace Enza.UTM.Web.Services.Controllers
{
    [RoutePrefix("api/v1/exceldata")]

    public class ExcelDataController : BaseApiController
    {
        private readonly IExcelDataService excelDataService;
        private readonly IFileService fileService;
        public ExcelDataController(IExcelDataService excelDataService, IFileService fileService)
        {
            this.excelDataService = excelDataService;
            this.fileService = fileService;
        }
        [Route("getdata")]
        [HttpPost]
        public async Task<IHttpActionResult> GetDataFromExcel([FromBody]ExcelDataRequestArgs args)
        {
            var result = await excelDataService.GetDataAsync(args);
            return Ok(result);
        }

        [Route("import")]
        [HttpPost]
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
            ////check if file is already exists for user
            //var fileExists = await fileService.FileExistsAsync(fileName);
            //if (fileExists)
            //{
            //    return InvalidRequest("File already exists.");
            //}
            var stream = await file.ReadAsStreamAsync();

            //save excel data to database
            var args = new ImportDataRequestArgs
            {
                TestTypeID = provider.FormData["testTypeID"].ToInt32(),
                PageNumber = provider.FormData["pageNumber"].ToInt32(),
                PageSize = provider.FormData["pageSize"].ToInt32(),
                PlannedDate = provider.FormData["plannedDate"].ToNDateTime(),
                MaterialStateID = provider.FormData["materialStateID"].ToInt32(),
                MaterialTypeID = provider.FormData["materialTypeID"].ToInt32(),
                ContainerTypeID = provider.FormData["containerTypeID"].ToInt32(),
                Isolated = provider.FormData["isolated"].ToBoolean(),
                Source = provider.FormData["source"],
                FilePath = fileName,
                TestName = System.IO.Path.GetFileNameWithoutExtension(fileName),
                DataStream = stream,
                ExpectedDate = provider.FormData["expectedDate"].ToNDateTime(),
                Cumulate = provider.FormData["cumulate"].ToBoolean(),
                ExcludeControlPosition = provider.FormData["excludeControlPosition"].ToBoolean()
            };
            var data = await excelDataService.ExportExcelDataToDBAsync(args);
            //get recently uploaded file details
            var fileInfo = await fileService.GetFileAsync(args.TestID);
            var result = new
            {
                data.Success,
                data.Errors,
                data.Total,
                data.DataResult,
                args.TestID,
                File = fileInfo
            };
            return Ok(result);
        }
    }
}
