using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Net.Http;
using System.Security.Claims;
using System.Threading.Tasks;
using System.Web.Http;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.Common.Extensions;
using Enza.UTM.Entities;
using Enza.UTM.Entities.Args;
using Enza.UTM.Services.Abstract;
using Enza.UTM.Services.Proxies;
using Enza.UTM.Web.Services.Core.Controllers;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace Enza.UTM.Web.Services.Controllers
{
    [RoutePrefix("api/v1/Master")]
    [Authorize(Roles = AppRoles.PUBLIC)]
    public class MasterController : BaseApiController
    {
        readonly IMasterService masterService;
        public MasterController(IMasterService masterService)
        {
            this.masterService = masterService;
        }

        [Route("getCrops")]
        [HttpGet]
        public async Task<IHttpActionResult> Get()
        {
            return Ok(await masterService.GetCropAsync());
            //var determminations = await determinationService.GetDeterminationsAsync(args);
            //return Ok(determminations);
        }

        [Route("getTraitValues")]
        [HttpGet]
        public async Task<IHttpActionResult> GetTraitValues(string cropCode, int traitID)
        {
            return Ok(await masterService.GetTraitValuesAsync(cropCode, traitID));
        }

        [Route("getbreedingstation")]
        [HttpGet]
        public async Task<IHttpActionResult> GetBreedingStation()
        {
            return Ok(await masterService.GetBreedingStationAsync());
        }

        [Route("getImportSources")]
        [HttpGet]
        public async Task<IHttpActionResult> GetImportSources()
        {
            var roles = User.GetClaims(ClaimTypes.Role);
            if (roles.Any(x => x.EqualsIgnoreCase("UTM_importExternal")))
            {
                var data1 = new[]
                {
                    new { SourceID = 1, SourceName= "Breezys", Code = "Breezys", LoginRequired = false },
                    new { SourceID = 2, SourceName= "Phenome", Code = "Phenome", LoginRequired = true },
                    new { SourceID = 3, SourceName= "External", Code = "External", LoginRequired = false }
                };
                return Ok(await Task.FromResult(data1));
            }

            var data2 = new[]
            {
                new { SourceID = 1, SourceName= "Breezys", Code = "Breezys", LoginRequired = false },
                new { SourceID = 2, SourceName= "Phenome", Code = "Phenome", LoginRequired = true }
            };
            return Ok(await Task.FromResult(data2));
        }

        [Route("getTestProtocols")]
        [HttpGet]
        public async Task<IHttpActionResult> GetTestProtocols()
        {
            var items = await masterService.GetTestProtocolsAsync();
            return Ok(items);
        }



        [HttpGet]
        [Route("getCNTProcesses")]
        public async Task<IHttpActionResult> GetCNTProcesses()
        {
            var items = await masterService.GetCNTProcessesAsync();
            return Ok(items);
        }

        [HttpPost]
        [Route("saveCNTProcesses")]
        public async Task<IHttpActionResult> SaveCNTProcesses([FromBody] IEnumerable<CNTProcessRequestArgs> requestArgs)
        {
            if (requestArgs == null)
                return InvalidRequest("Please provide required parameters.");

            await masterService.SaveCNTProcessAsync(requestArgs);
            return Ok();
        }

        [HttpGet]
        [Route("getCNTLabLocations")]
        public async Task<IHttpActionResult> GetCNTLabLocations()
        {
            var items = await masterService.GetCNTLabLocationsAsync();
            return Ok(items);
        }

        [HttpPost]
        [Route("saveCNTLabLocations")]
        public async Task<IHttpActionResult> SaveCNTLabLocations([FromBody] IEnumerable<CNTLabLocationRequestArgs> requestArgs)
        {
            if (requestArgs == null)
                return InvalidRequest("Please provide required parameters.");

            await masterService.SaveCNTLabLocationsAsync(requestArgs);
            return Ok();
        }

        [HttpGet]
        [Route("getCNTStartMaterials")]
        public async Task<IHttpActionResult> GetCnTStartMaterials()
        {
            var items = await masterService.GetCNTStartMaterialsAsync();
            return Ok(items);
        }

        [HttpPost]
        [Route("saveCNTStartMaterials")]
        public async Task<IHttpActionResult> SaveCNTStartMaterials([FromBody] IEnumerable<CNTStartMaterialRequestArgs> requestArgs)
        {
            if (requestArgs == null)
                return InvalidRequest("Please provide required parameters.");

            await masterService.SaveCNTStartMaterialsAsync(requestArgs);
            return Ok();
        }

        [HttpGet]
        [Route("getCNTTypes")]
        public async Task<IHttpActionResult> GetCnTTypes()
        {
            var items = await masterService.GetCNTTypesAsync();
            return Ok(items);
        }

        [HttpPost]
        [Route("saveCNTTypes")]
        public async Task<IHttpActionResult> SaveCNTTypes([FromBody] IEnumerable<CNTTypeRequestArgs> requestArgs)
        {
            if (requestArgs == null)
                return InvalidRequest("Please provide required parameters.");

            await masterService.SaveCNTTypesAsync(requestArgs);
            return Ok();
        }

        [Route("getUserCrops")]
        [HttpGet]
        public async Task<IHttpActionResult> GetUserGrops()
        {
            /*var config = new
            {
                instance = "https://login.microsoftonline.com",
                tenant = ConfigurationManager.AppSettings["ida:tenant"],
                client_id = ConfigurationManager.AppSettings["ida:audience"],
                client_secret = ConfigurationManager.AppSettings["ida:client_secret"],
                resource_id = "https://graph.microsoft.com/v1.0/me/"
            };
            using (var client = new RestClient(config.instance))
            {
                var response = await client.PostAsync($"/{config.tenant}/oauth2/v2.0/token", values =>
                {
                    values.Add("grant_type", "urn:ietf:params:oauth:grant-type:jwt-bearer");
                    values.Add("client_id", config.client_id);
                    values.Add("client_secret", config.client_secret);
                    values.Add("requested_token_use", "on_behalf_of");
                    values.Add("scope", "user.read");
                    values.Add("assertion", Request.Headers.Authorization.Parameter);
                });
                var result = await response.Content.ReadAsStringAsync();
                var tokens = (JObject)JsonConvert.DeserializeObject(result);
                var accessToken = tokens["access_token"].ToText();


                //call api
                using (var client2 = new HttpClient())
                {
                    var message = new HttpRequestMessage(HttpMethod.Get, "https://graph.microsoft.com/v1.0/me");
                    message.Headers.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", accessToken);
                    var resp = await client2.SendAsync(message);
                    var json = await resp.Content.ReadAsStringAsync();
                }
            }

            */


            var crops = await masterService.GetUserCropsAsync(User);
            return Ok(crops);
        }

        

    }
}
