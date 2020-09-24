using System.Configuration;
using System.Threading.Tasks;
using System.Web.Http;
using Enza.UTM.Entities.Args;
using Enza.UTM.Services.Abstract;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.Entities.Results;
using Enza.UTM.Common.Extensions;
using System.Web;
using Enza.UTM.Entities;
using Enza.UTM.Web.Services.Core.Controllers;

namespace Enza.UTM.Web.Services.Controllers
{
    [RoutePrefix("api/v1/phenome")]
    [Authorize(Roles = AppRoles.PUBLIC)]
    public class PhenomeController : BaseApiController
    {
        readonly IPhenomeServices phenomeService;
        private readonly IFileService fileService;
        private readonly string BASE_SVC_URL = ConfigurationManager.AppSettings["BasePhenomeServiceUrl"];

        public PhenomeController(IPhenomeServices phenomeService, IFileService fileService)
        {
            this.phenomeService = phenomeService;
            this.fileService = fileService;
        }

        [HttpPost]
        [Route("login")]
        public async Task<IHttpActionResult> Login(string userName, string password)
        {
            using (var client = new RestClient(BASE_SVC_URL))
            {
                var response = await client.PostAsync("/login_do", values =>
                {
                    values.Add("username", userName);
                    values.Add("password", password);
                });
                return ResponseMessage(response);
            }
        }

        [HttpPost]
        [Route("ssologin")]
        public async Task<IHttpActionResult> SSOLogin(string token)
        {
            using (var client = new RestClient(BASE_SVC_URL))
            {
                var response = await client.PostAsync("/single_sign_on", values =>
                {
                    values.Add("token", token);
                });
                await response.EnsureSuccessStatusCodeAsync();
                var result = await response.Content.DeserializeAsync<PhenomeSSOResult>();
                if(result.Status == "1")
                {
                    //get UUID from response to process futher(setting cookies in phenome)
                    if (string.IsNullOrWhiteSpace(result.UUID))
                    {
                        return InvalidRequest("UUID for the request is not available.");
                    }
                    //request for authentication cookies
                    //https://onprem.unity.phenome-networks.com/login_do?username=ronensh@phenome-test.co.il&password=FADC3116-E1B0-11E8-BC0B-B8211DFEC1A6
                    response = await client.GetAsync($"/login_do?username={HttpUtility.UrlEncode(result.UserName) }&password={ result.UUID }");
                    await response.EnsureSuccessStatusCodeAsync();
                }
                return ResponseMessage(response);
            }
        }

        [HttpGet]
        [Route("getResearchGroups")]
        public async Task<IHttpActionResult> GetResearchGroups()
        {
            using (var client = new RestClient(BASE_SVC_URL))
            {
                client.SetRequestCookies(Request);
                var response = await client.GetAsync("/api/v1/tree/baseobjectnavigator/get/m?path=m&selected=m");
                
                return ResponseMessage(response);
            }
        }

        [HttpGet]
        [Route("getFolders")]
        public async Task<IHttpActionResult> GetFolders(int id)
        {
            using (var client = new RestClient(BASE_SVC_URL))
            {
                client.SetRequestCookies(Request);
                var response = await client.GetAsync($"/api/v1/tree/baseobjectnavigator/get_node/m?id={id}");

                return ResponseMessage(response);
            }
        }

        [HttpPost]
        [Route("import")]
        public async Task<IHttpActionResult> Import([FromBody]PhenomeImportRequestArgs args)
        {
            if (string.IsNullOrWhiteSpace(args.TestName))
                return InvalidRequest("Please provide test name.");
            //if(await fileService.FileExistsAsync(args.TestName))
            //    return InvalidRequest("Test already exists.");
            if(string.IsNullOrWhiteSpace(args.FolderID))
            {
                return InvalidRequest("Invalid folder ID.");
            }
            if (string.IsNullOrWhiteSpace(args.CropID))
            {
                return InvalidRequest("Invalid research group ID.");
            }
            if (string.IsNullOrWhiteSpace(args.CropID))
            {
                var res = new ExcelDataResult();
                res.Errors.Add("Crop not found.");
                res.Success = false;
                return Ok(res);
            }
            var data = await phenomeService.GetPhenomeDataAsync(Request, args);
            var fileInfo = await fileService.GetFileAsync(args.TestID);
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


        [HttpPost]
        [Route("accessToken")]
        public async Task<IHttpActionResult> AccessToken()
        {
            var jwtToken = Request.Headers.Authorization;
            var token = await phenomeService.GetAccessTokenAsync(jwtToken.Parameter);
            return Ok(new
            {
                accessToken = token
            });
        }
    }
}