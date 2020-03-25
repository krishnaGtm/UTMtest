﻿using System.Threading.Tasks;
using System.Web.Http;
using Enza.UTM.BusinessAccess.Planning.Interfaces;
using Enza.UTM.Common.Extensions;
using Enza.UTM.Entities;
using Enza.UTM.Entities.Args;
using Enza.UTM.Web.Services.Core.Controllers;

namespace Enza.UTM.Web.Services.Planning.Controllers
{    
    [RoutePrefix("api/v1/Capacity")]
    public class CapacityController : BaseApiController
    {
        private readonly ICapacityService capacityService;
        public CapacityController(ICapacityService capacityService)
        {
            this.capacityService = capacityService;
        }

        [Authorize(Roles = "handlelabcapacity")]
        public async Task<IHttpActionResult> Get(int year)
        {
            var data = await capacityService.GetCapacityAsync(year);
            return Ok(data);
        }

        [Route("saveCapacity")]
        [HttpPost]
        [Authorize(Roles = "handlelabcapacity")]
        public async Task<IHttpActionResult> SaveCapacity([FromBody] SaveCapacityRequestArgs args)
        {
            var data = await capacityService.SaveCapacityAsync(args);
            return Ok(data);
        }

        [Route("reserveCapacity")]
        [HttpPost]
        [Authorize(Roles = "requesttest")]
        public async Task<IHttpActionResult> ReserveCapacity([FromBody] ReserveCapacityRequestArgs args)
        {
            var data = await capacityService.ReserveCapacityAsync(args);
            return Ok(data);
        }

        [HttpGet]
        [Route("getApprovalListForLab")]
        [Authorize(Roles = "handlelabcapacity")]
        public async Task<IHttpActionResult> GetApprovalListForLab(int periodID)
        {
            var data = await capacityService.GetPlanApprovalListForLabAsync(periodID);
            return Ok(data);
        }

        [HttpPost]
        [Route("MoveSlot")]
        [Authorize(Roles = "handlelabcapacity")]
        public async Task<IHttpActionResult> MoveSlot([FromBody] MoveSlotRequestArgs args)
        {
            var data = await capacityService.MoveSlotAsync(args);
            return Ok(data);
        }

        [HttpPost]
        [Route("deleteSlot")]
        [Authorize(Roles = AppRoles.MANAGE_MASTER_DATA_UTM_REQUEST_TEST)]
        public async Task<IHttpActionResult> DeleteSlot(int SlotID)
        {
            var args = new DeleteSlotRequestArgs
            {
                Crops = string.Join(",", User.GetClaims("enzauth.crops")),
                SlotID = SlotID,
                IsSuperUser = User.IsInRole(AppRoles.MANAGE_MASTER_DATA_UTM)
            };
            var data = await capacityService.DeleteSlotAsync(args);
            return Ok(data);
        }
    }
}