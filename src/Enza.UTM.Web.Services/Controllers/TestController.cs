using System.Threading.Tasks;
using System.Web.Http;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.Entities;
using Enza.UTM.Common.Extensions;
using Enza.UTM.Entities.Args;
using Enza.UTM.Web.Services.Core.Controllers;

namespace Enza.UTM.Web.Services.Controllers
{
    [RoutePrefix("api/v1/test")]
    [Authorize(Roles = AppRoles.PUBLIC)]
    public class TestController : BaseApiController
    {
        readonly ITestService testService;

        public TestController(ITestService testService)
        {
            this.testService = testService;
        }

        [HttpGet]
        [Route("gettestslookup")]
        public async Task<IHttpActionResult> GetLookup(string cropCode, string breedingStationCode)
        {
            var testLookups = await testService.GetLookupAsync(cropCode, breedingStationCode);
            return Ok(testLookups);
        }

        [Route("completeTestRequest")]
        public async Task<IHttpActionResult> Put([FromBody] CompleteTestRequestArgs args)
        {
            if (args == null)
                return InvalidRequest("Please specify required parameters.");
            //return test status to UI.
            var result1 = await testService.GetTestDetailAsync(new GetTestDetailRequestArgs
            {
                TestID = args.TestId
            });
            if (result1.StatusCode < 300)
                return InvalidRequest("Status canot be completed until we get response from LIMS system.");
            //update test status to 400 which is point of no return.
            var result = await testService.UpdateTestStatusAsync(new UpdateTestStatusRequestArgs
            {
                TestId = args.TestId,
                StatusCode = 400
            });
            //return test status to UI.
            result1 = await testService.GetTestDetailAsync(new GetTestDetailRequestArgs
            {
                TestID = args.TestId
            });

            return Ok(result1);
        }

        [HttpPut]
        [Route("saveremark")]
        public async Task<IHttpActionResult> SaveRemark([FromBody] SaveRemarkRequestArgs args)
        {
            if (args == null)
                return InvalidRequest("Please specify required parameters.");

            var result = await testService.SaveRemarkAsync(args);
            return Ok(result);
        }

        [HttpPost]
        [Route("printPlateLabels")]
        public async Task<IHttpActionResult> PrintPlateLabels([FromBody]PrintPlateLabelRequestArgs args)
        {
            if (args == null)
                return InvalidRequest("Please specify required parameters.");

            var result = await testService.PrintPlateLabelsAsync(args.TestID);
            return Ok(result);
        }

        [HttpPost]
        [Route("reserveplatesinlims")]
        public async Task<IHttpActionResult> ReservePlatesInLims([FromBody] ReservePlatesInLIMSRequestArgs args)
        {
            if (args == null)
                return InvalidRequest("Please specify required parameters.");

            var result = await testService.ReservePlatesInLIMSAsync(args.TestID);
            if(result.Success)
            {
                //update teststatus when reserveplateservice call is success.
                await testService.UpdateTestStatusAsync(new UpdateTestStatusRequestArgs
                {
                    StatusCode = 200,
                    TestId = args.TestID
                });
            }            
            //return test status to UI.
            var result1 = await testService.GetTestDetailAsync(new GetTestDetailRequestArgs
            {
                TestID = args.TestID
            }); 
            return Ok(result1);
        }

        [HttpPost]
        [Route("fillPlatesInLims")]
        public async Task<IHttpActionResult> FillPlatesInLims([FromBody]FillPlatesInLimsRequestArgs args)
        {
            if (args == null)
                return InvalidRequest("Please specify required parameters.");
            //return test status to UI.
            var result1 = await testService.GetTestDetailAsync(new GetTestDetailRequestArgs
            {
                TestID = args.TestID
            });
            if(result1.StatusCode < 400)
                return InvalidRequest("Unable to send request to LIMS without completing request.");

            await testService.FillPlatesInLimsAsync(args.TestID);
            //update teststatus when reserveplateservice call is success.
            await testService.UpdateTestStatusAsync(new UpdateTestStatusRequestArgs
            {
                StatusCode = 500,
                TestId = args.TestID
            });
            //return test status to UI.
            result1 = await testService.GetTestDetailAsync(new GetTestDetailRequestArgs
            {
                TestID = args.TestID
            });
            return Ok(result1);
            
        }

        [HttpGet]
        [Route("gettestdetail")]
        public async Task<IHttpActionResult> GetTestDetail([FromUri] GetTestDetailRequestArgs args)
        {
            if (args == null)
                return InvalidRequest("Please specify required parameters.");

            var result = await testService.GetTestDetailAsync(args);
            return Ok(result);
        }
        [HttpGet]
        [Route("getslotpertest")]
        public async Task<IHttpActionResult> GetSlotForTest([FromUri] int testID)
        {          

            var result = await testService.GetSlotForTest(testID);
            return Ok(result);
        }

        [HttpPut]
        [Route("saveplannedDate")]
        public async Task<IHttpActionResult> SavePlannedDate([FromBody] SavePlannedDateRequestArgs args)
        {
            if (args == null)
                return InvalidRequest("Please specify required parameters.");

            var result = await testService.SavePlannedDateAsync(args);
            return Ok(result);
        }

        [HttpGet]
        [Route("getContainerTypes")]
        public async Task<IHttpActionResult> GetContainerTypes()
        {
            var result = await testService.GetContainerTypeLookupAsync();
            return Ok(result);
        }

        [HttpPost]
        [Route("updateTest")]
        public async Task<IHttpActionResult> UpdateTest(UpdateTestArgs args)
        {
            var result = await testService.UpdateTest(args);
            return Ok(result);
        }
        [HttpPost]
        [Route("linkslotntest")]
        public async Task<IHttpActionResult> LinkSlotToTest([FromBody] SaveSlotTestRequestArgs args)
        {
            var result = await testService.LinkSlotToTest(args);
            return Ok(result);
        }

        [HttpPost]
        [Route("saveNrOfSamples")]
        public async Task<IHttpActionResult> SaveNrOfSamples([FromBody] SaveNrOfSamplesRequestArgs args)
        {
            await testService.SaveNrOfSamplesAsync(args);
            return Ok(true);
        }

        [HttpPost]
        [Route("deleteTest")]
        public async Task<IHttpActionResult> DeleteTest([FromBody] DeleteTestRequestArgs args)
        {
            return Ok(await testService.DeleteTestAsync(args));
        }

        [OverrideAuthorization]
        [Authorize(Roles = AppRoles.HANDLE_LAB_CAPACITY + "," + AppRoles.REQUEST_TEST)]
        [HttpPost]
        [Route("getPlatePlanOverview")]
        public async Task<IHttpActionResult> GetPlatePlanOverview([FromBody] PlatePlanRequestArgs args)
        {
            args.Crops = string.Join(",", User.GetClaims("enzauth.crops"));
            return Ok(await testService.getPlatePlanOverviewAsync(args));
        }
    }
}