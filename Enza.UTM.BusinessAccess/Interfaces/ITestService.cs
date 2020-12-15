using System.Collections.Generic;
using System.Data;
using System.Net.Http;
using System.Threading.Tasks;
using Enza.UTM.Entities;
using Enza.UTM.Entities.Args;
using Enza.UTM.Entities.Results;
using Enza.UTM.Services;
using Enza.UTM.Services.Abstract;

namespace Enza.UTM.BusinessAccess.Interfaces
{
    public interface ITestService
    {
        Task<IEnumerable<TestLookup>> GetLookupAsync(string cropCode, string breedingStationCode);
        Task<bool> UpdateTestStatusAsync(UpdateTestStatusRequestArgs request);
        Task<bool> SaveRemarkAsync(SaveRemarkRequestArgs request);
        Task<bool> SavePlannedDateAsync(SavePlannedDateRequestArgs request);
        Task<PrintLabelResult> PrintPlateLabelsAsync(int testID);
        Task<SoapExecutionResult> FillPlatesInLimsAsync(int testID);
        Task<SoapExecutionResult> ReservePlatesInLIMSAsync(int testID);
        Task<Test> GetTestDetailAsync(GetTestDetailRequestArgs request);
        Task<bool> ReservePlateplansInLIMSCallbackAsync(ReservePlateplansInLIMSCallbackRequestArgs args);
        Task<bool> ReserveScoreResult(ReceiveScoreArgs receiveScoreArgs);
        Task<IEnumerable<ContainerType>> GetContainerTypeLookupAsync();
        Task<bool> UpdateTest(UpdateTestArgs args);
        Task<IEnumerable<SlotForTestResult>>GetSlotForTest(int testID);
        Task<Test> LinkSlotToTest(SaveSlotTestRequestArgs args);
        Task<bool> ValidateAndSendTraitDeterminationResultAsync(string source);
        //Task<bool> CumulateAsync();
        //Task<List<MigrationDataResult>> CumulateAsync(List<TestResultCumulate> data);
        Task SaveNrOfSamplesAsync(SaveNrOfSamplesRequestArgs args);
        Task<string> DeleteTestAsync(DeleteTestRequestArgs args);
        Task<PlatePlanResult> getPlatePlanOverviewAsync(PlatePlanRequestArgs args);
        Task<byte[]> PlatePlanResultToExcelAsync(int testID, bool? withControlPosition);
        Task<byte[]> TestToExcelAsync(int testID);
        Task SendTestCompletionEmailAsync(string cropCode, string brStationCode, string platePlanName, string testName, int testID);
        Task<int> GetTotalMarkerAsync(int testID);
        Task<HttpResponseMessage> SignInAsync(RestClient client);        
    }
}
