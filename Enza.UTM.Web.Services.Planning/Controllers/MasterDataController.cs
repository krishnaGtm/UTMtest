using System.Threading.Tasks;
using System.Web.Http;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.BusinessAccess.Planning.Interfaces;
using Enza.UTM.Common.Extensions;
using Enza.UTM.Entities;
using Enza.UTM.Web.Services.Core.Controllers;

namespace Enza.UTM.Web.Services.Planning.Controllers
{
    [Authorize(Roles = AppRoles.PUBLIC_EXCEPT_ADMIN)]
    [RoutePrefix("api/v1/Planning/Master")]
    public class MasterDataController : BaseApiController
    {
        readonly IMasterDataService masterDataService;
        private readonly IMasterService _masterService;
        public MasterDataController(IMasterDataService masterDataService, IMasterService masterService)
        {
            this.masterDataService = masterDataService;
            _masterService = masterService;
        }
        [Route("breedingStationLookup")]
        public async Task<IHttpActionResult> GetBreedingStation()
        {
            var data = await masterDataService.GetBreedingStationAsync();
            return Ok(data);
        }
        [Route("cropLookup")]
        public async Task<IHttpActionResult> GetCrops()
        {
            var data = await masterDataService.GetCropsAsync();
            return Ok(data);
        }
        [Route("testTypeLookup")]
        public async Task<IHttpActionResult> GetTestType()
        {
            var data = await masterDataService.GetTestTypeAsync();
            return Ok(data);
        }
        [Route("MaterialTypeLookup")]
        public async Task<IHttpActionResult> GetMaterialType()
        {
            var data = await masterDataService.GetMaterialTypeAsync();
            return Ok(data);
        }
        [Route("MaterialTypePerCropLookup")]
        public async Task<IHttpActionResult> GetMaterialTypePerCrop([FromUri] string crop)
        {
            var data = await masterDataService.GetMaterialTypePerCropAsync(crop);
            return Ok(data);
        }
        [Route("MaterialStateLookup")]
        public async Task<IHttpActionResult> GetMaterialState()
        {
            var data = await masterDataService.GetMaterialStateAsync();
            return Ok(data);
        }
        [Route("ReserveCapacityLookup")]
        public async Task<IHttpActionResult> GetReserveCapacityPlanning()
        {
            //var cropCodes = User.GetClaims("enzauth.crops");
            var cropCodes = await _masterService.GetUserCropCodesAsync(User);
            var data = await masterDataService.GetReserveCapacityLookUp(cropCodes);
            return Ok(data);
        }

        [Route("PlanPeriods")]
        public async Task<IHttpActionResult> GetPlanPeriods(int? year = null)
        {
            var data = await masterDataService.GetPlanPeriodsAsync(year);
            return Ok(data);
        }

        [Route("DisplayPeriod")]
        public async Task<IHttpActionResult> GetDisplayPeriod([FromUri] string args)
        {
            var data = await masterDataService.GetDisplayPeriodAsync(args.ToDateTime());
            return Ok(data);
        }
    }
}
