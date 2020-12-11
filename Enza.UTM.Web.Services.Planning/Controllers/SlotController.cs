using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using System.Web.Http;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.BusinessAccess.Planning.Interfaces;
using Enza.UTM.Common.Extensions;
using Enza.UTM.Entities;
using Enza.UTM.Entities.Args;
using Enza.UTM.Entities.Results;
using Enza.UTM.Web.Services.Core.Controllers;

namespace Enza.UTM.Web.Services.Planning.Controllers
{
    [RoutePrefix("api/v1/Slot")]
    [Authorize(Roles = AppRoles.HANDLE_LAB_CAPACITY)]
    public class SlotController : BaseApiController
    {
        readonly ISlotService slotService;
        private readonly IMasterService _masterService;
        public SlotController(ISlotService slotService, IMasterService masterService)
        {
            this.slotService = slotService;
            _masterService = masterService;
        }

        [OverrideAuthorization]
        [Authorize(Roles = AppRoles.MANAGE_MASTER_DATA_UTM_REQUEST_TEST)]
        [Route("AvailablePlatesTests")]
        [HttpGet]        
        public async Task<IHttpActionResult> GetAvailPlatesTests([FromUri] GetAvailPlatesTestsRequestArgs args)
        {
            var data = await slotService.GetAvailPlatesTestsAsync(args);
            return Ok(data);
        }

        [Route("SlotDetail")]
        [HttpGet]
        public async Task<IHttpActionResult> GetSlotData([FromUri] int slotId)
        {
            var data = await slotService.GetSlotDataAsync(slotId);
            return Ok(data);
        }

        [Route("UpdateSlotPeriod")]
        [HttpPut]
        public async Task<IHttpActionResult> UpdateSlotPeriod([FromBody] UpdateSlotPeriodRequestArgs args)
        {
            //alllow overrides for this role only
            args.AllowOverride = User.IsInRole(AppRoles.HANDLE_LAB_CAPACITY);

            var data = await slotService.UpdateSlotPeriodAsync(args);
            return Ok(data);
        }
        [Route("approveSlot")]
        [HttpPost]
        public async Task<IHttpActionResult> ApproveSlotAsync([FromBody]ApproveSlotRequestArgs requestArgs)
        {           
            var data = await slotService.ApproveSlotAsync(requestArgs);
            return Ok(data);
        }
        [Route("denySlot")]
        [HttpPost]
        public async Task<IHttpActionResult> RejectSlot(int slotID)
        {
            var data = await slotService.DenySlotAsync(slotID);
            return Ok(data);
        }
       
        [HttpGet]
        [Route("plannedOverview")]
        public async Task<IHttpActionResult> PlannedOverview(int year, int? periodID = null)
        {
            var data = await slotService.GetPlannedOverviewAsync(year, periodID);
            return Ok(data);
        }

        [OverrideAuthorization]
        [Authorize(Roles = AppRoles.MANAGE_MASTER_DATA_UTM_REQUEST_TEST)]
        [HttpPost]
        [Route("breedingOverview")]
        public async Task<IHttpActionResult> BreedingOverview([FromBody]BreedingOverviewRequestArgs args)
        {
            var data = await slotService.GetBreedingOverviewAsync(args);
            return Ok(data);
        }

        [OverrideAuthorization]
        [Authorize(Roles = AppRoles.REQUEST_TEST)]
        [HttpPost]
        [Route("editSlot")]
        public async Task<IHttpActionResult> EditSlot([FromBody]EditSlotRequestArgs args)
        {
            var data = await slotService.EditSlotAsync(args);
            return Ok(data);
        }
        [OverrideAuthorization]
        [Authorize(Roles = AppRoles.PUBLIC)]
        [Route("GetApprovedSlots")]
        [HttpGet]
        public async Task<IHttpActionResult> GetApprovedSlots(bool userSlotsOnly, string slotName)
        {
            var userName = string.Empty;
            if (userSlotsOnly)
            {
                userName = User.Identity.Name;
            }
            //var crops = string.Join(",", User.GetClaims("enzauth.crops"));
            var cropCodes = await _masterService.GetUserCropCodesAsync(User);
            var crops = string.Join(",", cropCodes);
            var data = await slotService.GetApprovedSlotsAsync(userName, slotName, crops);
            return Ok(data);
        }

        [OverrideAuthorization]
        [Authorize(Roles = AppRoles.MANAGE_MASTER_DATA_UTM_REQUEST_TEST)]
        [HttpPost]
        [Route("ExportCapacityPlanningToExcel")]
        public async Task<IHttpActionResult> ExportCapacityPlanningToExcel([FromBody]BreedingOverviewRequestArgs args)
        {

            args.PageSize = 5000;
            args.PageNumber = 1;
            var data = await slotService.ExportCapacityPlanningToExcel(args);

            var result = new HttpResponseMessage(HttpStatusCode.OK)
            {
                Content = new ByteArrayContent(data)
            };
            result.Content.Headers.ContentDisposition = new ContentDispositionHeaderValue("attachment")
            {
                FileName = $"CapacityPlanning.xlsx"
            };
            result.Content.Headers.ContentType = new MediaTypeHeaderValue("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            return ResponseMessage(result);

        }
    }
}
